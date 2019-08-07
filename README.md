# Playground_RobotFramework

## Prerequisite
sudo apt-get update && \
sudo apt-get install python3 && \
if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
pip3 install --no-cache --upgrade pip setuptools wheel && \
if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
python3 -m pip install robotframework && \
pip3 install docker && \
pip3 install -U python-dotenv && \
pip3 install -U RESTinstance

## Run
robot -d report .
