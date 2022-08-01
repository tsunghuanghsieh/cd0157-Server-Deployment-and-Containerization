#!/usr/bin/python3

import json
import sys

if len(sys.argv) != 2:
    print("Please provide AWS account ID")
    sys.exit(1)

accountid = sys.argv[1]
with open("trust.json", 'r') as fin:
    jsonobj = json.load(fin)
    AWS_IAM = "arn:aws:iam::{}:root".format(accountid)
    jsonobj["Statement"][0]["Principal"]["AWS"] = AWS_IAM
    fin.close()
with open("trust.json", 'w') as fout:
    json.dump(jsonobj, fout, indent=4)
    fout.close()