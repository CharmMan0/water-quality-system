import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.impute import KNNImputer
from sklearn.feature_selection import SelectKBest, f_classif
import matplotlib.pyplot as plt
import seaborn as sns
import joblib

# 设置matplotlib支持中文
plt.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans', 'Arial Unicode MS']
plt.rcParams['axes.unicode_minus'] = False


# 1. 数据加载与基础清洗（仅去除重复值）
def load_data(file_path):

    df = pd.read_csv(file_path)

    # 去除重复值
    df = df.drop_duplicates()

    return df


# 2. 完整的预处理流程（仅在训练集上拟合）
def fit_preprocessing(X_train, y_train, k_features=9, method='anova'):

    # ==============================
    # 1. 缺失值处理：KNN填充
    # ==============================
    imputer = KNNImputer(n_neighbors=5)

    X_train_imputed = imputer.fit_transform(X_train)

    # ==============================
    # 2. 特征标准化
    # ==============================
    scaler = StandardScaler()

    X_train_scaled = scaler.fit_transform(X_train_imputed)

    # ==============================
    # 3. 特征选择
    # 注意：
    # 原始数据只有9个特征
    # 不适合复杂RFE
    # 使用ANOVA更加稳定
    # ==============================
    if method == 'anova':

        selector = SelectKBest(
            score_func=f_classif,
            k=k_features
        )

        X_train_selected = selector.fit_transform(
            X_train_scaled,
            y_train
        )

        selected_features = X_train.columns[
            selector.get_support()
        ]

    else:
        # 默认不做特征选择
        selector = None

        X_train_selected = X_train_scaled

        selected_features = X_train.columns

    # ==============================
    # 保存预处理工具
    # ==============================
    joblib.dump(imputer, "imputer.pkl")
    joblib.dump(scaler, "scaler.pkl")
    joblib.dump(selector, "selector.pkl")
    joblib.dump(selected_features, "selected_features.pkl")

    return (
        X_train_selected,
        y_train,
        imputer,
        scaler,
        selector,
        selected_features
    )


# 3. 使用已拟合的预处理工具转换数据（用于测试集和新数据）
def transform_data(X, imputer, scaler, selector):

    # ==============================
    # 1. 缺失值填充
    # ==============================
    X_imputed = imputer.transform(X)

    # ==============================
    # 2. 标准化
    # ==============================
    X_scaled = scaler.transform(X_imputed)

    # ==============================
    # 3. 特征选择
    # ==============================
    if selector is not None:
        X_selected = selector.transform(X_scaled)
    else:
        X_selected = X_scaled

    return X_selected


# 4. 特征分析与可视化
def analyze_features(df, target_col="Potability"):

    # ==============================
    # 相关性分析可视化
    # ==============================
    plt.figure(figsize=(12, 8))

    sns.heatmap(
        df.corr(),
        annot=True,
        cmap='coolwarm',
        fmt='.2f'
    )

    plt.title('水质特征相关性热力图')

    plt.savefig(
        'feature_correlation.png',
        dpi=300,
        bbox_inches='tight'
    )

    plt.close()

    # ==============================
    # 特征分布可视化
    # ==============================
    features = df.drop(target_col, axis=1).columns

    plt.figure(figsize=(15, 10))

    for i, feature in enumerate(features):

        plt.subplot(3, 3, i + 1)

        sns.histplot(
            data=df,
            x=feature,
            hue=target_col,
            kde=True
        )

        plt.title(f'{feature}分布')

    plt.tight_layout()

    plt.savefig(
        'feature_distribution.png',
        dpi=300,
        bbox_inches='tight'
    )

    plt.close()

    print("特征分析完成，已保存feature_correlation.png和feature_distribution.png")


# 测试代码
if __name__ == "__main__":

    import os

    # 加载本地数据集
    file_path = "water_potability.csv"

    print("数据集路径:", file_path)

    df = load_data(file_path)

    print("原始数据集形状：", df.shape)

    # 拆分特征与标签
    X = df.drop("Potability", axis=1)

    y = df["Potability"]

    # 拆分训练集和测试集
    from sklearn.model_selection import train_test_split

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )

    # 在训练集上拟合预处理工具
    (
        X_train_processed,
        y_train_processed,
        imputer,
        scaler,
        selector,
        features
    ) = fit_preprocessing(
        X_train,
        y_train,
        k_features=9,
        method='anova'
    )

    print("预处理完成，最终特征：", features.tolist())

    print("训练集处理后形状：", X_train_processed.shape)

    # 转换测试集
    X_test_processed = transform_data(
        X_test,
        imputer,
        scaler,
        selector
    )

    print("测试集处理后形状：", X_test_processed.shape)

    # 特征分析
    analyze_features(df)