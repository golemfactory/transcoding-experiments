import json
import sys


def updateJSONFile(template, output, key, value):
    with open(template, 'r') as f:
        params = json.load(f)

    params[key] = value

    with open(output, 'w+') as f:
        json.dump(params, f)


def run():
    template = sys.argv[1]
    output = sys.argv[2]
    key = sys.argv[3]
    value = sys.argv[4]

    updateJSONFile(template, output, key, value)


if __name__ == "__main__":
    run()
