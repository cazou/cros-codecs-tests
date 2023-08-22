#!/bin/env python3

import argparse
import jinja2
import os

DEVICE_TYPES = {
    "intel": "hp-x360-12b-ca0500na-n4000-octopus",
    "amd": "unknown"
}

def main():
    argparser = argparse.ArgumentParser()
    argparser.add_argument('--template', help='Input template file', required=True)
    argparser.add_argument('--arch', choices=['amd', 'intel'], help='Architecture', required=True)
    argparser.add_argument('--ccdec-build-id', help='ccdec build id', required=True)
    args = argparser.parse_args()

    env = jinja2.Environment(loader=jinja2.FileSystemLoader(os.path.dirname(args.template)),
                             undefined=jinja2.StrictUndefined)

    template = env.get_template(args.template)

    print(template.render(ccdec_build_id=args.ccdec_build_id, arch=args.arch, device_type=DEVICE_TYPES[args.arch]))


if __name__ == '__main__':
    main()

