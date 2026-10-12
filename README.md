# jubako — 日本語Debian Liveを作る、小さな作例

Debian 13のlive-buildから、labwc・Firefox・Xfce Terminal・fcitx5/Mozcを
組み合わせた日本語Live ISOを作るレシピです。自分のアプリや設定へ変更し、
自分のUSBで試すための出発点を目指しています。

**初回コミットのドラフトです。** ソース・依存検査と`lb config`による準備を行っていますが、
この切り出した作例のISOビルド・VM起動・実機起動はまだ未確認です。
元の個人用jubakoでの実機成功を、この作例の成功として扱っていません。

詳しいガイドは [docs/index.html](docs/index.html) から読めます。
GitHub Pagesを`main`ブランチの`/docs`に設定すると、そのまま公開できます。

## 最初の構築

構築ホストは **Debian 13・amd64**。WSL2のDebianも想定しています。
Ubuntuを構築ホストとして動作確認した、という意味ではありません。

```bash
# ホストへの構築ツール導入。Live内へのインストールではありません。
# sudoはパッケージ導入に必要です。
sudo apt update
sudo apt install live-build debootstrap xorriso squashfs-tools \
  dosfstools mtools syslinux-utils zstd python3 git

bash scripts/check.sh
bash scripts/check.sh --dependencies
bash scripts/prepare.sh
# sudoはchroot・一時マウント・構築用ファイルの作成に必要です。
sudo bash scripts/build.sh
```

成功すると`build/runs/<日時>/live-image-amd64.hybrid.iso`と`SHA256SUMS`ができます。
変更後や失敗後は`prepare.sh`で新しい作業先を作り、そこでビルドしてください。
成功後の設定・ログは`build/`にあり、Gitへ入れません。

初回USB作成はRufus等の信頼できるイメージ書き込みツールでユーザー自身が行います。
**選んだUSBの既存データは消えます。** 容量と機種名を確認し、必要なデータを退避してください。
このrepoにはディスクの選択・フォーマット・書き込みを自動実行するスクリプトはありません。

## 起動後

- 通常userでtty1にログインするとGUIを一度起動します。
- **Win+Enter**：端末。**デスクトップを右クリック**：アプリと設定のメニュー。
- **Win+Escape**：GUI終了。閉じた後は`start-desktop`で再度起動できます。
- 日本語入力はfcitx5＋Mozc。切替キーの確認・変更は右クリックの入力設定から。
- GUI起動失敗時はCUIへ戻ります。ログは`~/.cache/ja-live/desktop.log`です。
- 標準のkernel CUIは英語入力用。GUIの日本語表示とは別です。

この作例は`nopersistence`で動きます。Wi-Fi・設定・認証等をUSBへ保存しません。
再起動で消えるRAM環境なので、残す作業は別の保存媒体へ明示的に保存してください。

## 変更するところ

| 目的 | ファイル |
| --- | --- |
| Debian版、配列、ホスト名、起動条件 | `recipe/auto/config` |
| アプリやfirmwareを追加・削除 | `recipe/config/package-lists/desktop.list.chroot` |
| 構築中の設定・検査 | `recipe/config/hooks/live/` |
| OSへ収録するファイル | `recipe/config/includes.chroot/` |
| キー・メニュー | `includes.chroot/etc/xdg/labwc/` |

`auto/config`内の`--uefi-secure-boot enable`は維持する設計です。
firmware一覧はIntel PC向けの例です。他の機種は必要なパッケージを確認してください。
キャッシュが空の初回はネットワークが必要です。Debian版を指定してもAPTの更新で
内容が変わるため、完全に同じバイト列の再現は保証していません。

## 範囲

最初は単一のISOとRAMセッションだけを作ります。個人用のWindows運用、固定Lexar容量、
CF-SR用module/MOK鍵、AIバイナリや認証、旧データ移行は持ち込んでいません。
3区画・LUKS保存・3層高速更新・Zed/AIは、今後独立した例として追加する候補です。

自動ログインと通常userのsudo利用を含む、個人のLive作業向けの作例です。
共有端末向けのアクセス制御や全機種での動作を保証するものではありません。
Secure Bootでの実起動は別途確認が必要です。

## ライセンスと公開

独自のスクリプト・設定・説明は [MIT](LICENSE)。Debianパッケージのライセンスは別です。
[THIRD_PARTY.md](THIRD_PARTY.md) を参照してください。ISOやアプリのバイナリをrepoへ含めません。

GitHub Actionsはソース検査だけを行います。ISOの自動構築・公開はしません。
Pagesの設定手順と公開前チェックは [docs/publishing.html](docs/publishing.html) にあります。

初回コミット前の索引検査：

```bash
git add README.md LICENSE THIRD_PARTY.md .gitignore .github docs recipe scripts
python3 scripts/check-private.py
git diff --cached --check
git diff --cached
```

check-privateは典型的な秘密/個人パスと生成物の混入を探す補助です。
機密が絶対にないことを証明する検査ではありません。Gitの作者メールも公開されるので、
必要ならGitHubのSettings → Emailsにあるnoreplyアドレスを使ってください。
