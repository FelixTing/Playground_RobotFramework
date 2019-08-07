from robot.api import logger
import os
import platform
import sys
import subprocess
import http.client
import time
from dotenv import load_dotenv

services = {
    "core-data": {"composeName": "data", "port": 48080, "url": "/api/v1/ping"},
    "core-metadata": {"composeName": "metadata", "port": 48081, "url": "/api/v1/ping"},
    "core-command": {"composeName": "command", "port": 48082, "url": "/api/v1/ping"},
    "support-logging": {"composeName": "logging", "port": 48061, "url": "/api/v1/ping"},
    "support-notifications": {"composeName": "notifications", "port": 48060, "url": "/api/v1/ping"},
    "support-scheduler": {"composeName": "scheduler", "port": 48085, "url": "/api/v1/ping"},
    "export-client": {"composeName": "export-client", "port": 48071, "url": "/api/v1/ping"},
    "export-distro": {"composeName": "export-distro", "port": 48070, "url": "/api/v1/ping"},
    "support-rulesengine": {"composeName": "rulesengine", "port": 48075, "url": "/api/v1/ping"},
    "device-virtual": {"composeName": "device-virtual", "port": 49990, "url": "/api/v1/ping"},
}

class EdgeX(object):

    def __init__(self):
        load_dotenv(dotenv_path=get_env_file(), verbose=True)

    def deploy_edgex(self):
        # Deploy services
        cmd = docker_compose_cmd()
        cmd.extend(['up', '-d'])
        run_command(cmd)

        # Check services are started
        check_dependencies_services_startup(services)

    def shutdown_edgex(self):
        cmd = docker_compose_cmd()
        cmd.append('down')
        run_command(cmd)

        cmd = ['docker', 'volume', 'prune', '-f']
        run_command(cmd)


def docker_compose_cmd():
    cwd = str(os.getcwd())
    return ["docker", "run", "--rm",
            "--env-file", get_env_file(), "-e", "PWD=" + cwd,
            "-v", cwd + ":" + cwd, "-w", cwd, "-v",
            "/var/run/docker.sock:/var/run/docker.sock", get_docker_compose_image()]


def get_env_file():
    if platform.machine() == "aarch32":
        return "arm.env"
    elif platform.machine() == "aarch64":
        return "arm64.env"
    elif platform.machine() == "x86_64":
        return "x86_64.env"
    else:
        msg = "Unknow platform machine: " + platform.machine()
        logger.error(msg)
        raise Exception(msg)


def get_docker_compose_image():
    try:
        return str(os.environ["compose"])
    except KeyError:
        logger.error("Please set the environment variable: compose")
        sys.exit(1)


def run_command(cmd):
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    for line in p.stdout:
        logger.info(line, also_console=True)

    p.wait()
    logger.info("exit " + str(p.returncode))
    if p.returncode != 0:
        msg = "Fail to execute cmd: " + " ".join(str(x) for x in cmd)
        logger.error(msg)
        raise Exception(msg)
    else:
        msg = "Success to execute cmd: " + " ".join(str(x) for x in cmd)
        logger.info(msg)


def check_dependencies_services_startup(dependencies):
    for s in dependencies:
        logger.info("Check service " + s + " is startup...", also_console=True)
        check_service_startup(dependencies[s])


def check_service_startup(d):
    retrytimes = int(os.environ["retryFetchStartupTimes"])
    waittime = int(os.environ["waitTime"])
    for i in range(retrytimes):
        logger.info("Ping localhost " + str(d["port"]) + d["url"] + " ... ", also_console=True)
        conn = http.client.HTTPConnection(host="localhost", port=d["port"])
        conn.request(method="GET", url=d["url"])
        try:
            r1 = conn.getresponse()
        except:
            time.sleep(waittime)
            continue
        logger.info(r1.status, also_console=True)
        if int(r1.status) == 200:
            logger.info("Service is startup.", also_console=True)
            return True
        else:
            time.sleep(waittime)
            continue
    return False
