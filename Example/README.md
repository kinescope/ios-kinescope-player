# Example Of Kinescope iOS SDK

## About

This example shows how to use KinescopeSDK.

## Usage

### Install dependencies

 Run `make init` from `{Repository}/Example`

 This command will

 - update bundler to required version
 - install required gems
 - install required pods
 - generate project and workspace


### Configure apiKeys

Add `KinescopeConfig.plist` at path `{Repository}/Example/KinescopeExample` to add real **apiKey** for testing real user account. **Plist** can store multiple users.

`KinescopeConfig.plist` seems like usual property list.

```plist
<plist version="1.0">
<dict>
	<key>user0</key>
	<string>666</string>
	<key>user1</key>
	<string>1234</string>
	<key>user2</key>
	<string>9876</string>
</dict>
</plist>
```

`key` – convenient user's name, `string` – apiKey

 Run `make project` from `{Repository}/Example`

This command will generate project again with reference to config.

If you fill config correctly you got screen with your userNames. Like this

[![List](https://i.ibb.co/NjWHtq0/Simulator-Screen-Shot-i-Phone-8-2021-03-25-at-12-27-59.png)](https://ibb.co/DCwSzFB)

## License

[MIT License](LICENSE)
