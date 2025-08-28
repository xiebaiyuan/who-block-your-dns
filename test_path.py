#!/usr/bin/env python3
import os

# 模拟环境变量设置（与.env文件一致）
os.environ['RULE_SOURCES_CONFIG_FILE'] = 'data/rule_sources.json'

config_file = os.environ.get('RULE_SOURCES_CONFIG_FILE', 'data/rule_sources.json')
print('环境变量值:', repr(config_file))
print('是否绝对路径:', os.path.isabs(config_file))

if not os.path.isabs(config_file):
    # 获取当前脚本所在目录（模拟main.py的位置）
    script_dir = '/Users/xiebaiyuan/workspace/github/who-block-your-dns/backend-python'
    full_path = os.path.join(script_dir, config_file)
    print('脚本目录:', script_dir)
    print('完整路径:', full_path)
    print('文件是否存在:', os.path.exists(full_path))
else:
    print('使用绝对路径:', config_file)
    print('文件是否存在:', os.path.exists(config_file))
