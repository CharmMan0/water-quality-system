from sklearn.model_selection import (
    train_test_split,
    cross_val_score,
    GridSearchCV,
    StratifiedKFold
)

from sklearn.tree import DecisionTreeClassifier

from sklearn.ensemble import (
    RandomForestClassifier,
    GradientBoostingClassifier,
    VotingClassifier
)

from sklearn.svm import SVC

from sklearn.metrics import (
    accuracy_score,
    f1_score,
    confusion_matrix,
    roc_auc_score,
    roc_curve,
    classification_report
)

import numpy as np
import pandas as pd
import joblib
import os

import matplotlib.pyplot as plt
import seaborn as sns

from imblearn.over_sampling import SMOTE

from xgboost import XGBClassifier
from lightgbm import LGBMClassifier

from data_preprocess import (
    load_data,
    fit_preprocessing,
    transform_data,
    analyze_features
)

# 设置matplotlib支持中文
plt.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False


# 1. 数据集加载和预处理
def load_and_preprocess_data():

    # 本地数据集路径
    file_path = "water_potability.csv"

    print("数据集路径:", file_path)

    # 加载数据
    df = load_data(file_path)

    print("原始数据集形状：", df.shape)

    # ==============================
    # 拆分特征与标签
    # ==============================
    X = df.drop("Potability", axis=1)

    y = df["Potability"]

    # ==============================
    # 划分训练集和测试集
    # ==============================
    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )

    # ==============================
    # 数据预处理
    # ==============================
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

    # ==============================
    # 转换测试集
    # ==============================
    X_test_processed = transform_data(
        X_test,
        imputer,
        scaler,
        selector
    )

    # ==============================
    # SMOTE过采样
    # ==============================
    smote = SMOTE(random_state=42)

    X_train_balanced, y_train_balanced = smote.fit_resample(
        X_train_processed,
        y_train_processed
    )

    # 转换为DataFrame（避免LightGBM warning）
    X_train_balanced = pd.DataFrame(
        X_train_balanced,
        columns=features
    )

    X_test_processed = pd.DataFrame(
        X_test_processed,
        columns=features
    )

    print(f"SMOTE后训练集形状：{X_train_balanced.shape}")

    # 保存SMOTE
    joblib.dump(smote, "smote.pkl")

    return (
        X_train_balanced,
        X_test_processed,
        y_train_balanced,
        y_test,
        features
    )


# 2. ROC曲线绘制
def plot_roc_curve(y_test, y_pred_proba, model_name):

    # 计算ROC曲线
    fpr, tpr, _ = roc_curve(
        y_test,
        y_pred_proba
    )

    # 计算AUC
    auc_score = roc_auc_score(
        y_test,
        y_pred_proba
    )

    # 创建画布
    plt.figure(figsize=(6, 5))

    # ROC曲线
    plt.plot(
        fpr,
        tpr,
        linewidth=2,
        label=f'AUC = {auc_score:.4f}'
    )

    # 随机分类参考线
    plt.plot(
        [0, 1],
        [0, 1],
        linestyle='--'
    )

    plt.xlabel('False Positive Rate')

    plt.ylabel('True Positive Rate')

    plt.title(f'{model_name} ROC Curve')

    plt.legend(loc='lower right')

    # 保存图片
    plt.savefig(
        f'{model_name}_roc_curve.png',
        dpi=300,
        bbox_inches='tight'
    )

    # 关闭画布
    plt.close()

    print(f"{model_name} ROC曲线已保存")


# 3. 模型训练与评估
def train_traditional_models(
    X_train,
    X_test,
    y_train,
    y_test
):

    # ==============================
    # 定义模型
    # ==============================
    models = {

        "决策树": DecisionTreeClassifier(
            random_state=42,
            max_depth=5,
            min_samples_leaf=5
        ),

        "随机森林": RandomForestClassifier(
            n_estimators=200,
            random_state=42,
            class_weight='balanced'
        ),

        "SVM": SVC(
            probability=True,
            random_state=42,
            class_weight='balanced'
        ),

        "梯度提升树": GradientBoostingClassifier(
            random_state=42
        ),

        "XGBoost": XGBClassifier(
            n_estimators=200,
            random_state=42,
            eval_metric='logloss',
            max_depth=4,
            min_child_weight=3,
            subsample=0.8,
            colsample_bytree=0.8
        ),

        "LightGBM": LGBMClassifier(
            n_estimators=100,
            random_state=42,
            verbose=-1,
            is_unbalance=True
        )
    }

    # ==============================
    # 集成学习：Soft Voting
    # ==============================
    ensemble_model = VotingClassifier(

        estimators=[

            (
                'rf',
                RandomForestClassifier(
                    n_estimators=200,
                    random_state=42,
                    class_weight='balanced'
                )
            ),

            (
                'svm',
                SVC(
                    probability=True,
                    C=10,
                    gamma='scale',
                    kernel='rbf',
                    class_weight='balanced'
                )
            ),

            (
                'lgbm',
                LGBMClassifier(
                    n_estimators=100,
                    random_state=42,
                    verbose=-1,
                    is_unbalance=True
                )
            )
        ],

        # soft voting：按概率投票
        voting='soft'
    )

    # 加入模型字典
    models["集成学习Voting"] = ensemble_model

    # ==============================
    # 随机森林参数搜索
    # ==============================
    rf_param_grid = {

        'n_estimators': [150, 200],

        'max_depth': [4, 6, 8],

        'min_samples_leaf': [2, 5]
    }

    # ==============================
    # SVM参数搜索
    # ==============================
    svm_param_grid = {

        'C': [0.1, 1, 3, 5, 10],

        'gamma': ['scale', 0.1, 0.01, 0.001],

        'kernel': ['rbf']
    }

    results = []

    best_model = None

    best_score = 0

    # ==============================
    # 训练模型
    # ==============================
    for name, model in models.items():

        print(f"\n正在训练 {name}...")

        # ==============================
        # 随机森林调参
        # ==============================
        if name == "随机森林":

            grid_search = GridSearchCV(
                model,
                rf_param_grid,
                cv=5,
                scoring='f1',
                n_jobs=-1
            )

            grid_search.fit(X_train, y_train)

            model = grid_search.best_estimator_

            print(f"随机森林最优参数：{grid_search.best_params_}")

        # ==============================
        # SVM调参
        # ==============================
        elif name == "SVM":

            grid_search = GridSearchCV(
                model,
                svm_param_grid,
                cv=5,
                scoring='f1',
                n_jobs=-1
            )

            grid_search.fit(X_train, y_train)

            model = grid_search.best_estimator_

            print(f"SVM最优参数：{grid_search.best_params_}")

        else:

            model.fit(X_train, y_train)

        # ==============================
        # 概率预测
        # ==============================
        y_pred_proba = model.predict_proba(X_test)[:, 1]

        # ==============================
        # Threshold Tuning
        # ==============================
        best_threshold = 0.5

        best_f1 = 0

        for threshold in np.arange(0.45, 0.66, 0.01):

            y_pred_temp = (
                y_pred_proba >= threshold
            ).astype(int)

            temp_f1 = f1_score(
                y_test,
                y_pred_temp
            )

            if temp_f1 > best_f1:

                best_f1 = temp_f1

                best_threshold = threshold

        # 使用最佳threshold预测
        y_pred = (
            y_pred_proba >= best_threshold
        ).astype(int)

        print(f"{name}最佳Threshold: {best_threshold:.2f}")

        # ==============================
        # 模型评估
        # ==============================
        acc = accuracy_score(y_test, y_pred)

        f1 = f1_score(y_test, y_pred)

        auc = roc_auc_score(y_test, y_pred_proba)

        cv_score = cross_val_score(
            model,
            X_train,
            y_train,
            cv=5,
            scoring='f1'
        ).mean()

        results.append({

            "模型": name,

            "准确率": round(acc, 4),

            "F1-Score": round(f1, 4),

            "AUC": round(auc, 4),

            "交叉验证F1": round(cv_score, 4)
        })

        # ==============================
        # 分类报告
        # ==============================
        print(f"{name} 分类报告：")

        print(classification_report(
            y_test,
            y_pred
        ))

        # ==============================
        # ROC曲线
        # ==============================
        plot_roc_curve(
            y_test,
            y_pred_proba,
            name
        )

        # ==============================
        # 混淆矩阵
        # ==============================
        cm = confusion_matrix(y_test, y_pred)

        plt.figure(figsize=(6, 4))

        sns.heatmap(
            cm,
            annot=True,
            fmt='d',
            cmap='Blues',
            xticklabels=['不合格', '合格'],
            yticklabels=['不合格', '合格']
        )

        plt.title(f'{name}混淆矩阵')

        plt.ylabel('真实标签')

        plt.xlabel('预测标签')

        plt.savefig(
            f'{name}_confusion_matrix.png',
            dpi=300,
            bbox_inches='tight'
        )

        plt.close()

        # ==============================
        # 保存最佳模型
        # ==============================
        if f1 > best_score:

            best_score = f1

            best_model = model

            joblib.dump(model, "best_model.pkl")

            joblib.dump(
                best_threshold,
                "best_threshold.pkl"
            )

            print(
                f"新的最优模型：{name}，F1-Score：{f1:.4f}"
            )

    # ==============================
    # 保存结果
    # ==============================
    result_df = pd.DataFrame(results)

    result_df.to_csv(
        "model_evaluation.csv",
        index=False
    )

    print("\n所有模型训练完成，评估结果：")

    print(result_df)

    # ==============================
    # 模型性能对比图
    # ==============================
    plt.figure(figsize=(12, 6))

    x = np.arange(len(result_df["模型"]))

    width = 0.2

    plt.bar(
        x - 0.2,
        result_df["准确率"],
        width,
        label='准确率'
    )

    plt.bar(
        x,
        result_df["F1-Score"],
        width,
        label='F1-Score'
    )

    plt.bar(
        x + 0.2,
        result_df["AUC"],
        width,
        label='AUC'
    )

    plt.xlabel('模型')

    plt.ylabel('得分')

    plt.title('模型性能对比')

    plt.xticks(
        x,
        result_df["模型"],
        rotation=15
    )

    plt.legend()

    plt.ylim(0, 1)

    plt.savefig(
        'model_comparison.png',
        dpi=300,
        bbox_inches='tight'
    )

    plt.close()

    return best_model


# 4. 特征重要性分析
def analyze_feature_importance(model, features):

    if hasattr(model, 'feature_importances_'):

        importance = model.feature_importances_

        feature_importance = pd.DataFrame({

            '特征': features,

            '重要性': importance

        }).sort_values(
            '重要性',
            ascending=False
        )

        plt.figure(figsize=(10, 6))

        sns.barplot(
            x='重要性',
            y='特征',
            data=feature_importance
        )

        plt.title('特征重要性分析')

        plt.tight_layout()

        plt.savefig(
            'feature_importance.png',
            dpi=300,
            bbox_inches='tight'
        )

        plt.close()

        print("\n特征重要性：")

        print(feature_importance)

        joblib.dump(
            feature_importance,
            "feature_importance.pkl"
        )


# 主程序
if __name__ == "__main__":

    # 加载和预处理数据
    (
        X_train,
        X_test,
        y_train,
        y_test,
        features
    ) = load_and_preprocess_data()

    # 模型训练
    best_model = train_traditional_models(
        X_train,
        X_test,
        y_train,
        y_test
    )

    # 特征重要性分析
    analyze_feature_importance(
        best_model,
        features
    )

    print("\n所有训练任务完成！")

    print("生成文件：")

    print("- best_model.pkl")

    print("- best_threshold.pkl")

    print("- model_evaluation.csv")

    print("- feature_importance.png")

    print("- *_roc_curve.png")

    print("- *_confusion_matrix.png")

    print("- model_comparison.png")