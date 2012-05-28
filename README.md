pbs4p
=====

pbs4p は Postfix で POP before SMTP を利用する為のスクリプトです。
設定例はDovecotとの連携を前提に書いていますが、認証後に顔部プログラムを実行可能なメールサーバなら対応は簡単です。

# セットアップ
まずは適当な場所に clone してファイルの権限設定をしておきます

    git clone https://github.com/kawaz/pbs4p.git /var/lib/pbs4p
    chgrp postfix /var/lib/pbs4p/db/allow_clients
    postmap /var/lib/pbs4p/db/allow_clients

Dovecotで認証成功したクライアントのIPを記録する為、`dovecot.conf`に以下の設定を追加します。

    service pop3 {
      executable = pop3 pbs4p-record-ip
    }
    service imap {
      executable = imap pbs4p-record-ip
    }
    service pbs4p-record-ip {
      executable = script-login /var/lib/pbs4p/bin/record-ip.sh
      user = $default_internal_user
      unix_listener pbs4p-record-ip {
      }
    }

Postfixで登録されたIPからのリレーを許可する為、`main.cf`で`smtpd_recipient_restrictions`や必要なら`smtpd_client_restrictions`の設定を変更します。
以下はとあるサーバでの設定例です。`check_client_access`を適切な位置に追加します。

    ## 接続元によるアクセス制御 (DNSBL)
    smtpd_client_restrictions =
      permit_mynetworks
      ## SASL認証済みなら許可
      permit_sasl_authenticated
      ## POP/IMAP認証から一定期時間内のIPなら許可
      check_client_access hash:/var/lib/pbs4p/db/allow_clients
      ## DNSBL
      reject_rbl_client zen.spamhaus.org
      reject_rbl_client bl.spamcop.net
      reject_rbl_client all.rbl.jp
      ## デフォルトは許可
      permit

    ## リレー制御
    smtpd_recipient_restrictions =
      permit_mynetworks
      ## 受信者アドレスがFQDNでない場合拒否する
      reject_non_fqdn_recipient
      ## SASL認証済みなら許可
      permit_sasl_authenticated
      ## POP/IMAP認証から一定期時間内のIPなら許可
      check_client_access hash:/var/lib/pbs4p/db/allow_clients
      ## オープンリレー禁止
      reject_unauth_destination

期限切れのIP情報を削除する為、crontabに以下を追加します。`clean.sh`は第1引数に有効期限を指定することが出来ます。デフォルトは`600`秒です。

    * * * * * /var/lib/pbs4p/bin/clean.sh

