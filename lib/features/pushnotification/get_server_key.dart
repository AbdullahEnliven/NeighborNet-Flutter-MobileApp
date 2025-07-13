import 'package:googleapis_auth/auth_io.dart';

// ignore: camel_case_types
class get_server_key {
  // ignore: non_constant_identifier_names
  Future<String> get_server_key_token() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "neighbournet-bd503",
        "private_key_id": "d9d27f0d52b2c79b8b65f042a907438648637eb4",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCy89Vsqx/uVoyb\nWhoFFQej8WY6YCnNmsSJP5FuMoPkGCF9dzKsQu+kzoTPCs6yQtTM1PdVkqay+C8h\n9L76WeugELnkKGcDbqrRA2fjPjSJe2ASoQEoubS3LBRW66a52wkffYJ27s3qOfpE\nxUsIpa5UQKMq1XrXtBzFHzQdqLcg6u/XAqOG/9wtxkNb2+HwQCz7dNJBJDtOW4Qh\n/9upy502wZS8e+xEhdy//vC+sMYGYSwoqVGwGJ73dmK/J6t4eNfs7s0vcCgZvZGk\nR+h0a/LA5zN6fknqX5AKKLKyivCW6Pi7DhyOsUaqK9IujkZ5CsbcXUfFEGnD0Wuh\nyepqj3CXAgMBAAECggEATeAeuLOfqbCwb8q+GAgW0xlyS2UdzAPWE4Q+XZ5OFy0J\nJfiBbMWUVDwrP46MdLbwtFLZb7vqH2gx2q0PjxMinv2oZ8nNSokWfO7mftXLNykh\nnfnC714hbrUYBNt4KtlPFw0fgXJa2dtxNgxFovW276NRXoqYctZGzuHNZDrPttrM\nPl8i/weAfa1YEPDoYXtGa0N6+yoWGyPYqNCIZ0rN3+jwdcFt2x8dq9M69NKA9xCH\n6xBdId+WB5B9LyOD9XNdgjOQwYZgjXNICqbG2hWKj97FO8FLr6zQSgsynwXk3GYp\n/z4KrQUSxxmPop1jg4RI0QJUonjVrRAAaDvjxUOyAQKBgQDa+AuhSW6HllMZRJ4F\nL2TUc0ZZLAuQ8Lez7jStLGIapWdd574zOC2lWXrX5K/2Klxy8M4kE/fNdxZPTyXh\nFts+uKPYReOAK9JxH+NfYmkqKDxALfhtHb3BT0mfBfx8Nezf1t6XMSocPQRxNnzC\n2C09fSMITWK9WGCoeL6jIZ8odwKBgQDRN1TsSIg3CBDzGaym8l9VBsOi9ZkxUf1A\n5qjq60BjhZYZi2gqZOmff1qaLfiS4Rp9p/KodJc7kkTjsA34ZwHjsTs0M87YcCVj\nB/U3s+a8e9w8zxXYVqUccBYvOpcuM1vVV5UvhprqQ2TJfF4mxVimjQN6hf29UFFC\nw2U4MdIg4QKBgQDDbxIKQR0KnQvMCKc1H4jR6ZUHL72e/oonaNrRGUTyXWB1usnS\nszhiVQvEN1Mp1cMvv2dtYfkRBFIANTcswBas02VBOZeEpRgtaXWpg48zVjf4XE9X\nLG1ZZKfj7Bbe0c56Ni/zJ6lbDMazORt/WCyArfifh1oyfve+Rg54USDZnwKBgDpY\nqQlgTQSz7i4t2dWRQH7w7Px0a+2yROOlsDQbuZBHwA2NsFYqYHEHzlezPGCSAJZM\nkULjiQ2nBClPfwXojEFYuv8a97OqyvJsVLndJRspm8klo5z6xP9CTx2KxICw+Apu\na3+elXOBqgj68zLy1H9WUkMIPTRfwtnQrljWpBhhAoGBAM/ICPJWKsKmFpj5FpIS\nB9H343YWG6wqkt3rzrJdHhxMeuygw74LrTDVKd+KUYtqnDnuH6RmH5pZm+PUMYM9\nxeLG5Cnce/BhkOTbMmdP/DkXx0Z/NY2CEIsBkRIQ2xkU6eYqx2sel6kEvj0cXzRV\nu00IYI6SuEOZTuoQlDwB67WW\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@neighbournet-bd503.iam.gserviceaccount.com",
        "client_id": "106665790310054469905",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40neighbournet-bd503.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );
    final accessserverkey = client.credentials.accessToken.data;
    return accessserverkey;
  }
}
