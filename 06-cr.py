#!/usr/bin/env python3


from collections import defaultdict
from glob import glob
import json
import os
from statistics import mean
import sys

from tabulate import tabulate

DEDUPLICATE = 'deduplicate'
DEOBFUSCATE = 'deobfuscate'


def summarize(reports):
    result = defaultdict(list)
    num_reports = 0

    report = {}
    for report_path in reports:
        with open(report_path, 'r') as report_file:
            reports = json.load(report_file)['reports']
            if not reports:
                continue
            elif len(reports) > 1:
                raise Exception('%s contains multiple reports' % report_path)

        report = reports[0]
        result['loc'].append(report['aggregate']['sloc']['physical'])
        result['functions'].append(len(report['functions']))
        result['cyclomatic'].append(report['aggregate']['cyclomatic'])
        result['halstead'].append(report['aggregate']['halstead']['length'])
        num_reports += 1

    # Compute statistics
    result['total loc'] = sum(result['loc'])
    result['total functions'] = sum(result['functions'])

    if num_reports >= 1:
        result['mean cyclomatic'] = mean(result['cyclomatic'])
        result['mean halstead'] = mean(result['halstead'])
    else:
        result['mean cyclomatic'] = 'N/A'
        result['mean halstead'] = 'N/A'

    return result


def main():
    if len(sys.argv) != 2:
        print('Usage: %s /path/to/output/dir' % sys.argv[0])
        sys.exit(1)

    out_dir = sys.argv[1]

    # Only get reports for samples that were successfully deobfuscated
    get_reports = lambda d: [os.path.join(out_dir, d, name) for name in
                             os.listdir(os.path.join(out_dir, 'deobfuscate')) if
                             name.endswith('.json')]
    get_num_samples = lambda d: len(glob(os.path.join(out_dir, d, '*.json')))

    dedup_result = summarize(get_reports(DEDUPLICATE))
    dedup_result['dir'] = DEDUPLICATE
    dedup_result['num samples'] = get_num_samples(DEDUPLICATE)

    deob_result = summarize(get_reports(DEOBFUSCATE))
    deob_result['dir'] = DEOBFUSCATE
    deob_result['num samples'] = get_num_samples(DEOBFUSCATE)

    header = ('dir', 'num samples', 'total loc', 'total functions',
              'mean cyclomatic', 'mean halstead')
    result = [[d[k] for k in header] for d in (dedup_result, deob_result)]
    print(tabulate(result, headers=header))


if __name__ == '__main__':
    main()
