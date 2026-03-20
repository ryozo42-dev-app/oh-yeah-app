#!/bin/bash
# エラーが発生したら即座に停止
set -e

echo "=========================================="
echo "🧹 Flutter iOS 環境の完全クリーンアップ & 再構築"
echo "=========================================="

# 0. プロジェクトルートにいることを確認
if [ ! -f "pubspec.yaml" ]; then
    echo "エラー: このスクリプトはFlutterプロジェクトのルートディレクトリで実行してください。"
    exit 1
fi

# 1. 古いiOS関連ファイルと不要なディレクトリを削除
echo "[1/5] 古いiOS関連ファイルと不要なディレクトリを削除しています..."
rm -rf ios/Pods
rm -f ios/Podfile.lock
rm -rf ios/Runner.xcworkspace
rm -rf ios/Flutter
# プロジェクトに紛れ込んだ不要なディレクトリも削除
rm -rf ios/ios_old
rm -rf ios/windows
rm -rf ios/web
rm -rf ios/linux

# 2. Flutterプロジェクトのクリーンアップ
echo "[2/5] 'flutter clean' を実行しています..."
flutter clean

# 3. 依存関係の取得 (これにより ios/Flutter/Flutter.podspec が再生成される)
echo "[3/5] 'flutter pub get' を実行しています..."
flutter pub get

# 4. CocoaPodsの依存関係をインストール
echo "[4/5] CocoaPodsの依存関係をインストールしています (cd ios && pod install --repo-update)..."
cd ios
pod install --repo-update
cd ..

echo "=========================================="
echo "✅ 環境の再構築が完了しました。"
echo "Xcodeで 'ios/Runner.xcworkspace' を開いてビルド、または 'flutter run' を実行してください。"
echo "=========================================="