# README

## 確認済みの再現環境

Windows:

  * Windows Server 2012 R2
  * Windows 10

MariaDB + Mroonga：

   * [mariadb-10.1.19-with-mroonga-6.11-winx64.zip](https://github.com/mroonga/mroonga/releases/download/v6.11/mariadb-10.1.19-with-mroonga-6.11-winx64.zip)
   * [mariadb-10.1.29-with-mroonga-7.09-winx64.zip](https://github.com/mroonga/mroonga/releases/download/v7.09/mariadb-10.1.29-with-mroonga-7.09-winx64.zip)

## 確認方法

Windowsを用意します。たとえばWindows 10など再現が確認されていない環境でも大丈夫です。その環境では再現しないことがわかるというのも重要な情報です。

上述の再現が確認されているMariaDB + Mroongaのどれかをダウンロードして、展開します。

このリポジトリーをcloneします。次のファイルを個別にダウンロードしてもよいです。

  * https://github.com/mroonga/windows-resource-leak-test/blob/master/MySql.Data.dll
  * https://github.com/mroonga/windows-resource-leak-test/blob/master/my.ini
  * https://github.com/mroonga/windows-resource-leak-test/blob/master/query.ps1
  * https://github.com/mroonga/windows-resource-leak-test/blob/master/searchStr.txt
  * https://github.com/mroonga/windows-resource-leak-test/blob/master/xxxxxxxx_dat_static_page2.sql

テスト用クエリー実行スクリプト`query.ps1`では`C:\Administrator\windows-resource-leak-test\`以下にこのリポジトリーの内容があることを仮定しているので、別の場所にclone・ダウンロードした場合は`query.ps1`を書き換えてください。

このリポジトリー内にある`my.ini`を使って`mysqld.exe`を起動します。

```text
> cd ...\mariadb-10.1.29-with-mroonga-7.09-winx64
> bin\mysqld.exe --defaults-file=C:\Users\Administrator\windows-resource-leak-test\my.ini
```

別のターミナルでテスト用のデータベースを作ります。

```text
> cd ...\mariadb-10.1.29-with-mroonga-7.09-winx64
> bin\mysql.exe -u root -e 'create database mroonga_test'
```

このリポジトリー内のテストデータ`xxxxxxxx_dat_static_page2.sql`をテスト用のデータベースにロードします。

```text
> cd ...\mariadb-10.1.29-with-mroonga-7.09-winx64
> bin\mysql.exe -u root mroonga_test < C:\Users\Administrator\windows-resource-leak-test\xxxxxxxx_dat_static_page2.sql
```

このリポジトリー内のテストスクリプト`query.ps1`を実行します。セキュリティーのため、PowerShellスクリプトはデフォルトでは実行できないようになっています。管理者権限で[`Set-ExecutionPolicy Unrestricted`](https://technet.microsoft.com/ja-jp/library/ee176961.aspx)を実行して制限を緩める必要があります。

```text
> cd C:\Users\Administrator\windows-resource-leak-test
> Set-ExecutionPolicy Unrestricted
> .\query.ps1
```

このスクリプトを実行し続け、約52万クエリー発行程度で以下のどれかの問題が発生するはずです。

  * `mysqld.exe`が次のようなエラーログを出力する

    ```text
    2018-01-18 21:12:52 3620 [ERROR] Error in accept: システムのバッファー領域が不足しているか、またはキューがいっぱいなため、ソケット操作を実行できませんでした。
    ```

  * `mysqld.exe`が停止する

  * `mysqld.exe`は停止しないが、接続を受け付けない

なお、ターミナルを複数立ち上げて同時に実行すると問題発生までの時間が短くなります。

## 補足情報

  * 再現する環境と再現しない環境があることを確認済みです。再現するかどうかの違いがどこからくるかわかっていないので、それを知りたいです。

  * ストレージエンジンをMroongaからMyISAMに変更するとすでに再現している環境でも再現しなくなります。

## License

MySql.Data.dll: [GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

Extracted from [MySQL Connector/Net](https://dev.mysql.com/downloads/connector/net/6.9.html).

Others: Public domain
