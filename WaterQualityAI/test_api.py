"""
批量调用水质AI预测API进行测试
读取 test_data_50samples.csv，逐条调用 API，保存完整结果
"""
import requests
import pandas as pd
import json
import time
import sys
import os
os.chdir(os.path.dirname(os.path.abspath(__file__)))

API_BASE = "http://127.0.0.1:8000"
INPUT_CSV = "test_data_50samples.csv"
OUTPUT_CSV = "test_results_50samples.csv"

# ---------- 1. 检查 API 是否在线 ----------
print("[*] 检查 API 服务状态...")
try:
    r = requests.get(f"{API_BASE}/", timeout=5)
    print(f"    API 在线: {r.json()}")
except Exception as e:
    print(f"[ERROR] 无法连接 API ({API_BASE})，请先运行: python ai_api.py")
    print(f"   错误: {e}")
    sys.exit(1)

# ---------- 2. 加载测试数据 ----------
try:
    df = pd.read_csv(INPUT_CSV, encoding='utf-8-sig')
    print(f"\n[*] 已加载测试数据: {INPUT_CSV} ({len(df)} 条)")
except FileNotFoundError:
    print(f"[ERROR] 找不到 {INPUT_CSV}，请先运行: python generate_test_data.py")
    sys.exit(1)

# ---------- 3. 批量预测 ----------
results = []

print(f"\n>>> 开始批量预测 ({len(df)} 条)...\n")
start_time = time.time()

for idx, row in df.iterrows():
    payload = {
        "pH": float(row['pH']),
        "hardness": float(row['Hardness']),
        "solids": float(row['Solids']),
        "chloramines": float(row['Chloramines']),
        "sulfate": float(row['Sulfate']),
        "conductivity": float(row['Conductivity']),
        "organic_carbon": float(row['Organic_carbon']),
        "trihalomethanes": float(row['Trihalomethanes']),
        "turbidity": float(row['Turbidity']),
    }

    try:
        resp = requests.post(f"{API_BASE}/predict/single", json=payload, timeout=10)
        if resp.status_code == 200:
            result = resp.json()
        else:
            result = {"error": f"HTTP {resp.status_code}", "detail": resp.text}
    except Exception as e:
        result = {"error": str(e)}

    # 合并输入 + 输出
    record = {**payload, **result}
    record['sample_index'] = idx + 1
    record['expected_category'] = row['expected_category']
    results.append(record)

    # 打印进度
    pred = result.get('prediction', 'ERROR')
    prob = result.get('probability', 'N/A')
    grade = result.get('water_grade', 'N/A')
    symbol = "[SAFE]" if pred == "Safe" else ("[UNSAFE]" if pred == "Unsafe" else "[ERR]")
    print(f"  [{idx+1:2d}/50] {symbol} {pred:6s} | prob={prob:.4f}" if isinstance(prob, float) else f"  [{idx+1:2d}/50] {symbol} {pred:6s} | prob={prob}",
          f"| grade={grade} | expected={row['expected_category']}",
          flush=True)

elapsed = time.time() - start_time
print(f"\n[OK] 耗时: {elapsed:.2f}s ({elapsed/len(df)*1000:.0f}ms/条)")

# ---------- 4. 保存结果 ----------
result_df = pd.DataFrame(results)

# 调整列顺序：元数据 → 输入 → 输出
meta_cols = ['sample_index', 'expected_category']
input_cols = ['pH', 'hardness', 'solids', 'chloramines', 'sulfate',
              'conductivity', 'organic_carbon', 'trihalomethanes', 'turbidity']
output_cols = ['prediction', 'probability', 'threshold', 'water_grade',
               'wqi_score', 'standard_level', 'model_name', 'timestamp']

# 只保留实际存在的列
available_cols = meta_cols + input_cols + output_cols
available_cols = [c for c in available_cols if c in result_df.columns]
# 加上 error/detail（如果有）
extra_cols = [c for c in result_df.columns if c not in available_cols]
result_df = result_df[available_cols + extra_cols]

result_df.to_csv(OUTPUT_CSV, index=False, encoding='utf-8-sig')
print(f"[OK] 结果已保存: {OUTPUT_CSV}")

# ---------- 5. 汇总统计 ----------
safe_count = len(result_df[result_df.get('prediction') == 'Safe'])
unsafe_count = len(result_df[result_df.get('prediction') == 'Unsafe'])
error_count = len(result_df) - safe_count - unsafe_count

print(f"\n>>> 预测结果汇总:")
print(f"   Safe:   {safe_count} 条")
print(f"   Unsafe: {unsafe_count} 条")
if error_count > 0:
    print(f"   Error:  {error_count} 条")

# 分类别统计
print(f"\n   交叉对比（预期 vs 预测）：")
for cat in ['Safe', 'Borderline', 'Unsafe']:
    subset = result_df[result_df['expected_category'] == cat]
    if len(subset) == 0:
        continue
    s = len(subset[subset.get('prediction') == 'Safe'])
    u = len(subset[subset.get('prediction') == 'Unsafe'])
    e = len(subset) - s - u
    print(f"   预期 {cat:12s} ({len(subset):2d}条) → Safe:{s:2d}  Unsafe:{u:2d}" + (f"  Error:{e}" if e > 0 else ""))

# 水质等级分布
if 'water_grade' in result_df.columns:
    print(f"\n   水质等级分布：")
    for g in ['Excellent', 'Good', 'Fair', 'Poor', 'Dangerous']:
        cnt = len(result_df[result_df['water_grade'] == g])
        if cnt > 0:
            print(f"     {g:12s}: {cnt} 条")

print(f"\n[OK] 测试完成!")
