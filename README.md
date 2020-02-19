# cifs-client

## 主な用途

* 継続的デプロイ（Continuous deployment; CD）で Windows 共有フォルダをリモートマウントしてファイルを配置する。
* rsync コマンドを使用して内容差分があるファイルだけを転送する。
* 自動マウントには未対応のため、コンテナ内で mount コマンドを使用してリモートマウントする。

## 他の方法との比較

* Windows クライアントの場合、[robocopy][robocopy] コマンドで /mir オプションを使用することで指定フォルダをミラーリングできるが、ファイルの内容に差分がないファイルも含めてすべてコピーされる。
* [rsync][rsync] コマンドで --checksum オプションを使用すれば、ファイルの内容に差分があるファイルのみ転送できる。

[robocopy]: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy
[rsync]: https://linux.die.net/man/1/rsync

## 使い方

GitLab-CICD で自動デプロイに使用する例

**.gitlab-ci.yml**

```yml
stages:
    - deploy
deploy-job:
    stage: deploy
    tags:
        - docker
    image: k1tajima/sshfs-client
    variables:
        SRC: deploy/files/path
        DEST: //remote-host/folder/path
    script:
        - echo Deploy $SRC to $DEST
        ## See also https://linux.die.net/man/8/mount.cifs
        - mount.cifs -o "user=${USER},pass={$PASS}" $DEST /mnt/remote
        ## ミラーリング（チェックサムによる更新判定・削除反映）
        - rsync -rlvh --checksum --delete $SRC/ /mnt/remote
        - ls -alR /mnt/remote > remote_ls-alR.txt
        - umount /mnt/remote
    artifacts:
        paths:
            - remote_ls-alR.txt
```

なお、GitLab-Runner の設定で Docker イメージ実行オプションに privileged = true が追加されていること。

> https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersdocker-section

以上
