import argparse
import time

import boto3


def get_new_api_task_definition(stage, new_image, service_name_):
    return {
        "family": f"{service_name_}-api",
        "volumes": [],
        "requiresCompatibilities": ["FARGATE"],
        "cpu": "512",
        "memory": "1024",
        "networkMode": "awsvpc",
        "executionRoleArn": f"arn:aws:iam::106967885159:role/{service_name_}-app-execution-role",
        "taskRoleArn": f"arn:aws:iam::106967885159:role/{service_name_}-ecs-host-role",
        "containerDefinitions": [
            {
                "name": "talk-booking-app",
                "logConfiguration": {
                    "logDriver": "awslogs",
                    "options": {
                        "awslogs-group": f"/ecs/{service_name_}",
                        "awslogs-region": "eu-west-1",
                        "awslogs-stream-prefix": f"{service_name_}-app-log-stream",
                    },
                },
                "command": "gunicorn --bind 0.0.0.0:5000 web_app.main:app -k uvicorn.workers.UvicornWorker".split(),
                "workingDirectory": "/home/app/web",
                "memory": 1024,
                "cpu": 512,
                "environment": [
                    {"name": "APP_ENVIRONMENT", "value": stage},
                ],
                "image": new_image,
                "portMappings": [
                    {"hostPort": 5000, "protocol": "tcp", "containerPort": 5000}
                ],
            }
        ],
    }


def create_new_task_definition(client, new_task_definition):
    return client.register_task_definition(**new_task_definition)["taskDefinition"][
        "taskDefinitionArn"
    ]


def update_service(client, cluster, service, task_arn):
    client.update_service(
        cluster=cluster,
        service=service,
        taskDefinition=task_arn,
    )


def wait_to_finish_deployment(client, cluster, service, timeout, task_definition_arn):
    sleep_seconds = 10
    timeout = int(timeout / sleep_seconds)
    cnt = 0
    deployment_finished = False

    while cnt < timeout:
        response = client.describe_services(cluster=cluster, services=[service])
        deployment = next(
            depl
            for depl in response["services"][0]["deployments"]
            if depl["status"] == "PRIMARY"
        )
        sum_running = sum(
            depl["runningCount"] for depl in response["services"][0]["deployments"]
        )
        new_deployment_created = int(task_definition_arn.split(":")[-1]) < int(
            response["services"][0]["taskDefinition"].split(":")[-1]
        )

        if (
            deployment["runningCount"] == deployment["desiredCount"]
            and sum_running == deployment["desiredCount"]
        ) or new_deployment_created:
            deployment_finished = True
            break
        print(
            f"Waiting ... Running count: {deployment['runningCount']}; "
            f"Desired count: {deployment['desiredCount']}; "
            f"All count: {sum_running}"
        )
        time.sleep(sleep_seconds)

    print(f"Deployment finished: {deployment_finished}")
    return deployment_finished


if __name__ == "__main__":
    DEPLOYMENT_TIMEOUT = 1800  # seconds

    parser = argparse.ArgumentParser()
    parser.add_argument("--cluster_name", help="Name of ECS cluster")
    parser.add_argument("--service_name", help="Service name")
    parser.add_argument("--stage", help="App environment")
    parser.add_argument("--new_image_uri", help="URI of new Docker image")

    args = parser.parse_args()
    cluster_name = args.cluster_name
    service_name = args.service_name
    new_image_uri = args.new_image_uri
    stage = args.stage

    ecs_client = boto3.client("ecs")

    new_task_definition_ = get_new_api_task_definition(
        stage=stage, new_image=new_image_uri, service_name_=service_name
    )
    new_task_arn = create_new_task_definition(ecs_client, new_task_definition_)

    update_service(
        ecs_client,
        cluster=cluster_name,
        service=service_name,
        task_arn=new_task_arn,
    )
    finished = wait_to_finish_deployment(
        ecs_client,
        cluster=cluster_name,
        service=service_name,
        timeout=DEPLOYMENT_TIMEOUT,
        task_definition_arn=new_task_arn,
    )

    if not finished:
        print("Did not stabilize ...")
        exit(1)
