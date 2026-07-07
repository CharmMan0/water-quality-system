import joblib

# 加载训练时保存的特征列表
try:
    selected_features = joblib.load("selected_features.pkl")
    print("="*50)
    print("✅ 成功加载特征列表")
    print("="*50)
    print("训练时使用的特征顺序（非常重要！）：")
    print("-"*50)
    for i, feature in enumerate(selected_features, 1):
        print(f"{i}. {feature}")
    print("="*50)
    print("⚠️  预测时必须严格按照这个顺序输入数值！")
    print("="*50)
except FileNotFoundError:
    print("❌ 错误：找不到selected_features.pkl文件")
    print("请确保你在WaterQualityAI文件夹中运行此脚本")
except Exception as e:
    print(f"❌ 发生错误：{str(e)}")

# 按回车键退出
input("\n按回车键退出...")