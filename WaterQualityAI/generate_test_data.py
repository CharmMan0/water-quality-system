"""
批量生成水质测试数据
覆盖3类场景：安全饮用水 / 临界值 / 超标污染
"""
import pandas as pd
import numpy as np
import os
os.chdir(os.path.dirname(os.path.abspath(__file__)))

np.random.seed(42)
N = 50  # 总共50条测试样本

# 安全饮用水典型值范围（基于GB5749-2022）
SAFE_RANGES = {
    'pH':               (6.5, 8.5),
    'Hardness':         (50, 350),
    'Solids':           (50, 800),
    'Chloramines':      (0.5, 3.0),
    'Sulfate':          (30, 200),
    'Conductivity':     (100, 700),
    'Organic_carbon':   (0.5, 1.8),
    'Trihalomethanes':  (10, 60),
    'Turbidity':        (0.2, 4.0),
}

# 安全门阈值（来自 ai_api.py _safety_gate）
GATES = {
    'pH':               (5.0, 10.0),
    'Hardness':         600,
    'Solids':           1500,
    'Chloramines':      6,
    'Sulfate':          400,
    'Conductivity':     1500,
    'Organic_carbon':   5,
    'Trihalomethanes':  120,
    'Turbidity':        8,
}

samples = []

# ============================================
# 类别A：安全饮用水（20条）
# ============================================
for i in range(20):
    sample = {}
    sample['pH'] =                round(np.random.uniform(6.5, 8.5), 2)
    sample['Hardness'] =          round(np.random.uniform(50, 350), 1)
    sample['Solids'] =            round(np.random.uniform(50, 800), 1)
    sample['Chloramines'] =       round(np.random.uniform(0.5, 3.0), 2)
    sample['Sulfate'] =           round(np.random.uniform(30, 200), 1)
    sample['Conductivity'] =      round(np.random.uniform(100, 700), 1)
    sample['Organic_carbon'] =    round(np.random.uniform(0.5, 1.8), 2)
    sample['Trihalomethanes'] =   round(np.random.uniform(10, 60), 1)
    sample['Turbidity'] =         round(np.random.uniform(0.2, 4.0), 2)
    sample['expected_category'] = 'Safe'
    samples.append(sample)

# ============================================
# 类别B：临界值（10条）— 部分指标接近安全门
# ============================================
for i in range(10):
    sample = {}
    sample['pH'] =                round(np.random.choice([np.random.uniform(5.5, 6.5),
                                                          np.random.uniform(8.5, 9.5)]), 2)
    sample['Hardness'] =          round(np.random.uniform(400, 580), 1)
    sample['Solids'] =            round(np.random.uniform(900, 1400), 1)
    sample['Chloramines'] =       round(np.random.uniform(3.5, 5.5), 2)
    sample['Sulfate'] =           round(np.random.uniform(250, 380), 1)
    sample['Conductivity'] =      round(np.random.uniform(800, 1400), 1)
    sample['Organic_carbon'] =    round(np.random.uniform(2.5, 4.5), 2)
    sample['Trihalomethanes'] =   round(np.random.uniform(80, 115), 1)
    sample['Turbidity'] =         round(np.random.uniform(5.0, 7.5), 2)
    sample['expected_category'] = 'Borderline'
    samples.append(sample)

# ============================================
# 类别C：超标污染（20条）— 至少1项超过安全门
# ============================================
for i in range(20):
    sample = {}
    # 基础值随机取安全/临界范围
    sample['pH'] =                round(np.random.uniform(5.5, 9.0), 2)
    sample['Hardness'] =          round(np.random.uniform(100, 500), 1)
    sample['Solids'] =            round(np.random.uniform(200, 1300), 1)
    sample['Chloramines'] =       round(np.random.uniform(1.0, 5.0), 2)
    sample['Sulfate'] =           round(np.random.uniform(50, 350), 1)
    sample['Conductivity'] =      round(np.random.uniform(200, 1300), 1)
    sample['Organic_carbon'] =    round(np.random.uniform(1.0, 4.0), 2)
    sample['Trihalomethanes'] =   round(np.random.uniform(20, 100), 1)
    sample['Turbidity'] =         round(np.random.uniform(1.0, 6.0), 2)

    # 随机选择 1-3 个指标故意拉高到超标
    indicators = ['pH', 'Hardness', 'Solids', 'Chloramines', 'Sulfate',
                  'Conductivity', 'Organic_carbon', 'Trihalomethanes', 'Turbidity']
    n_exceed = np.random.randint(1, 4)
    exceed_indicators = np.random.choice(indicators, n_exceed, replace=False)

    for ind in exceed_indicators:
        if ind == 'pH':
            sample['pH'] = round(np.random.choice([
                np.random.uniform(3.0, 5.0),   # 严重偏酸
                np.random.uniform(10.0, 13.0)  # 严重偏碱
            ]), 2)
        elif ind == 'Hardness':
            sample['Hardness'] = round(np.random.uniform(650, 1200), 1)
        elif ind == 'Solids':
            sample['Solids'] = round(np.random.uniform(1800, 5000), 1)
        elif ind == 'Chloramines':
            sample['Chloramines'] = round(np.random.uniform(7, 15), 2)
        elif ind == 'Sulfate':
            sample['Sulfate'] = round(np.random.uniform(450, 800), 1)
        elif ind == 'Conductivity':
            sample['Conductivity'] = round(np.random.uniform(1800, 3000), 1)
        elif ind == 'Organic_carbon':
            sample['Organic_carbon'] = round(np.random.uniform(6, 15), 2)
        elif ind == 'Trihalomethanes':
            sample['Trihalomethanes'] = round(np.random.uniform(150, 300), 1)
        elif ind == 'Turbidity':
            sample['Turbidity'] = round(np.random.uniform(10, 30), 2)

    sample['expected_category'] = 'Unsafe'
    samples.append(sample)

# 构建 DataFrame
df = pd.DataFrame(samples)
cols = ['pH', 'Hardness', 'Solids', 'Chloramines', 'Sulfate',
        'Conductivity', 'Organic_carbon', 'Trihalomethanes', 'Turbidity',
        'expected_category']
df = df[cols]

# 保存
csv_path = 'test_data_50samples.csv'
df.to_csv(csv_path, index=False, encoding='utf-8-sig')
print(f"[OK] 测试数据已生成：{csv_path}")
print(f"   共 {len(df)} 条样本")
print(f"   安全: {len(df[df['expected_category']=='Safe'])} 条")
print(f"   临界: {len(df[df['expected_category']=='Borderline'])} 条")
print(f"   超标: {len(df[df['expected_category']=='Unsafe'])} 条")
print(f"\n前5条预览：")
print(df.head().to_string())
print(f"\n各指标统计：")
print(df.iloc[:, :9].describe().to_string())
