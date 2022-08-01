#!/usr/bin/python3

import yaml

# https://gist.github.com/paulkernstock/6df1c7ad37fd71b1da3cb05e70b9f522
from yaml.representer import SafeRepresenter

class LiteralString(str):
    pass

def change_style(style, representer):
    def new_representer(dumper, data):
        scalar = representer(dumper, data)
        scalar.style = style
        return scalar
    return new_representer

represent_literal_str = change_style('|', SafeRepresenter.represent_str)

yaml.add_representer(LiteralString, represent_literal_str)


# Addd the following to the configmap, replace account_id
#     - groups:
#       - system:masters
#       rolearn: arn:aws:iam::<account_id>:role/UdacityFlaskDeployCBKubectlRole
#       username: build
newRole = """-groups:
  - system:masters
  rolearn: arn:aws:iam::{}:role/UdacityFlaskDeployCBKubectlRole
  username: build
""".format("675061576913")

ConfigmapFile = "aws-auth-patch.yaml"
with open(ConfigmapFile, 'r')  as fin:
    yamlobj = yaml.load(fin, Loader=yaml.SafeLoader)
    mapRoles = yamlobj["data"]["mapRoles"]
    if mapRoles.find(newRole) == -1:
        mapRoles = "{}{}".format(mapRoles, newRole)
    fin.close()

with open(ConfigmapFile, 'w')  as fout:
    yamlobj["data"]["mapRoles"] = LiteralString(mapRoles)
    yaml.dump(yamlobj, fout)
    fout.close()