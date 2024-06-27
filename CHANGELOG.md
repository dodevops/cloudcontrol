## [7.0.0](https://github.com/dodevops/cloudcontrol/compare/v6.0.0...v7.0.0) (2024-06-27)


### ⚠ BREAKING CHANGES

* Removed bitwarden feature
* Bitwarden feature not available anymore

### Features

* Add missing annotations to multi arch images ([cbabee6](https://github.com/dodevops/cloudcontrol/commit/cbabee65a1bf947a228073132d23105c6302377d))
* Adding azure relogin feature ([90f5cf0](https://github.com/dodevops/cloudcontrol/commit/90f5cf0f208b73c4868bdefcffa3d8d7206cf8f4))
* Adding sops feature ([251dad5](https://github.com/dodevops/cloudcontrol/commit/251dad5a487fa5a2882fe1cbf43e087099b2e5d7))
* Include cmctl ([c4aba15](https://github.com/dodevops/cloudcontrol/commit/c4aba15a45168af7afe6e5893d24dbf5fac94d8a)), closes [#140](https://github.com/dodevops/cloudcontrol/issues/140)
* Optimized documentation and feature utils ([9c84998](https://github.com/dodevops/cloudcontrol/commit/9c849988efb2701588fdf403da6f8cac8f98f95b))
* Optimized test runner to work more smoothly ([271e8d3](https://github.com/dodevops/cloudcontrol/commit/271e8d31b9d5c75ba07d3b064678a887bbb990d7))
* Support ARM environment variable instead of special AZ variables ([e69fa5f](https://github.com/dodevops/cloudcontrol/commit/e69fa5f006ad10da014c5b8a47e3c77cab8ed45c))
* Support for k9s ([1b70bfa](https://github.com/dodevops/cloudcontrol/commit/1b70bfa98a86ded461bb88f6d30cc6b740af3467)), closes [#96](https://github.com/dodevops/cloudcontrol/issues/96)
* Support krew ([12f9af0](https://github.com/dodevops/cloudcontrol/commit/12f9af0fddcc4361432cf74fde4bee2bfdbc07c8)), closes [#95](https://github.com/dodevops/cloudcontrol/issues/95)
* Supports azure arm64 image ([dbbfa9b](https://github.com/dodevops/cloudcontrol/commit/dbbfa9be5ffc148fbeb065994ce497cbd09fd798))


### Bug Fixes

* Correct TENANTID variable after deprecation ([1b8ec9d](https://github.com/dodevops/cloudcontrol/commit/1b8ec9dfb61cce73bc9a260a9a1967e04ffd062d))
* Fixed azure flavourinit ([8a7dc42](https://github.com/dodevops/cloudcontrol/commit/8a7dc42941138d6678b88e9b4bf75811cf659a79))
* Fixed azure relogin script escaping ([8bf0200](https://github.com/dodevops/cloudcontrol/commit/8bf02005b89bdde0f595595f2c2c2fa7e46813db))
* Fixed krew installation messing up the path variable ([fa30818](https://github.com/dodevops/cloudcontrol/commit/fa3081817646ddee4383064c02a34a6a3a63b9ad))
* Fixed test runner not ignoring .-directories ([6423833](https://github.com/dodevops/cloudcontrol/commit/64238336ec51b994acd1201b7f98194711b7dac4))
* Fixed test runner not ignoring .-directories ([2ea77f6](https://github.com/dodevops/cloudcontrol/commit/2ea77f6ac6236f82eee428758830273653c53b93))
* Fixing README template section about building README.md ([5af3b64](https://github.com/dodevops/cloudcontrol/commit/5af3b64a526532ddc6d21583374c09a78cbf5a0f))
* Moved integration skip to the bash version of the feature test ([4686af2](https://github.com/dodevops/cloudcontrol/commit/4686af24fe5df3c7f2c04b6c18ea88a7a0285af7))
* Put a sleep in the RunCommand implementation ([49df0b9](https://github.com/dodevops/cloudcontrol/commit/49df0b9e6aabae6bc72ced54c1002f532a47fc24))
* Remove template from doc generation ([ac7b3e4](https://github.com/dodevops/cloudcontrol/commit/ac7b3e4189fd8bb229ed4d2c0fe9e37c9a9b205f))
* Removed bitwarden because of very unstable implementation ([876a83c](https://github.com/dodevops/cloudcontrol/commit/876a83c617534755a79aaca7b7425a4e52cfd080))
* Some PR fixes ([224fadb](https://github.com/dodevops/cloudcontrol/commit/224fadbab221b69418f8548bdae7dc0d8a048e7c))
* Some PR fixes ([e573a1d](https://github.com/dodevops/cloudcontrol/commit/e573a1dc33bb437f0f176761232e5c15183d5f67))
* Updated goss to work with optimized testrunner ([979dcdf](https://github.com/dodevops/cloudcontrol/commit/979dcdfbdffcf8aed0f7b1ed9b50c466437e543d))


### Documentation

* added note about timeframe for deprecation ([fef840a](https://github.com/dodevops/cloudcontrol/commit/fef840ab958e8d925816f83e5969f21ce95f56be))
* Automatic docs update ([6d090e9](https://github.com/dodevops/cloudcontrol/commit/6d090e992a466594311a2abb92846185459e2196))
* Automatic docs update ([72662a1](https://github.com/dodevops/cloudcontrol/commit/72662a135a018705976f66db178522dcd12e6f22))
* Automatic docs update ([d314dce](https://github.com/dodevops/cloudcontrol/commit/d314dce6e4f84eb66f2fbc60b467401ee8c29741))
* Automatic docs update ([380fb7c](https://github.com/dodevops/cloudcontrol/commit/380fb7cb4488fae13c5575cd53ee4d1836466d21))
* Automatic docs update ([782c4fa](https://github.com/dodevops/cloudcontrol/commit/782c4fa50b2c970dc18e2ec50e99e9ac4d879328))
* Automatic docs update ([4fb0418](https://github.com/dodevops/cloudcontrol/commit/4fb0418a1561ac7f4a582c98d7e8f4436d2c9f95))
* Automatic docs update ([bc91cd5](https://github.com/dodevops/cloudcontrol/commit/bc91cd5e635fac43c8a862f7afd8e69c91145085))
* Fixed generated readme ([25c0841](https://github.com/dodevops/cloudcontrol/commit/25c08410b643c5d1e1bb678c5d3a07b002517738))



## [6.0.0](https://github.com/dodevops/cloudcontrol/compare/v5.1.0...v6.0.0) (2024-06-11)


### ⚠ BREAKING CHANGES

* Removed bitwarden feature
* Bitwarden feature not available anymore

### Features

* Add missing annotations to multi arch images ([c913909](https://github.com/dodevops/cloudcontrol/commit/c9139097a2ed9806e8c0ed1163ec5d6ed18839ce))
* Adding azure relogin feature ([a8e9b51](https://github.com/dodevops/cloudcontrol/commit/a8e9b51b8a3aeb9d8d05946b21df1c7e02819054))
* Optimized test runner to work more smoothly ([589274d](https://github.com/dodevops/cloudcontrol/commit/589274db334cb7eee06a29041fac8c1eab6497e2))
* Support ARM environment variable instead of special AZ variables ([62f33ab](https://github.com/dodevops/cloudcontrol/commit/62f33ab2678402892f5e005b795f2451151604f3))
* Support for k9s ([392f6ed](https://github.com/dodevops/cloudcontrol/commit/392f6ed859ffa41db0d85b5e591558f342af961b)), closes [#96](https://github.com/dodevops/cloudcontrol/issues/96)
* Support krew ([ced91ea](https://github.com/dodevops/cloudcontrol/commit/ced91eaa354e8279e0033e7bdd70335e07755fec)), closes [#95](https://github.com/dodevops/cloudcontrol/issues/95)
* Supports azure arm64 image ([9d911ba](https://github.com/dodevops/cloudcontrol/commit/9d911bac98e518f7ccf75aa4159bfa621ac1e895))


### Bug Fixes

* Correct TENANTID variable after deprecation ([5b1e2a1](https://github.com/dodevops/cloudcontrol/commit/5b1e2a190f43cad3f389ef77ce319a2fda73850b))
* Fixed azure flavourinit ([41999a9](https://github.com/dodevops/cloudcontrol/commit/41999a9af92811daff46def22d2be1865529c67d))
* Fixed azure relogin script escaping ([509d6d2](https://github.com/dodevops/cloudcontrol/commit/509d6d23cde0bdaedb01a0be542cd6706c730a73))
* Fixed krew installation messing up the path variable ([7665e7d](https://github.com/dodevops/cloudcontrol/commit/7665e7d57ac8af3741a422a6e70f10701ad5ca7a))
* Moved integration skip to the bash version of the feature test ([aa922db](https://github.com/dodevops/cloudcontrol/commit/aa922db41a8a7984534c067fb52834c9db770678))
* Put a sleep in the RunCommand implementation ([ab5ab3c](https://github.com/dodevops/cloudcontrol/commit/ab5ab3cd978310b08bc0beb15d58c710c2c7958f))
* Removed bitwarden because of very unstable implementation ([54828e9](https://github.com/dodevops/cloudcontrol/commit/54828e9ebed8f69c60690de741d33039ecf56610))
* Updated goss to work with optimized testrunner ([4f15402](https://github.com/dodevops/cloudcontrol/commit/4f15402f8868fc8ea79d2f261d0fc82572d69edf))


### Documentation

* added note about timeframe for deprecation ([085e168](https://github.com/dodevops/cloudcontrol/commit/085e168b7aae2b9cddadad00069d7f8ff4837885))
* Automatic docs update ([eb907c1](https://github.com/dodevops/cloudcontrol/commit/eb907c16937d588e3d8c7e2da845a8b39a07c63a))
* Automatic docs update ([83d81f1](https://github.com/dodevops/cloudcontrol/commit/83d81f1132fbcfcaa98142850c6df0a326c24f62))
* Automatic docs update ([efaf35c](https://github.com/dodevops/cloudcontrol/commit/efaf35c0cdf64455269d70c565adda540789ee2f))



## [5.1.0](https://github.com/dodevops/cloudcontrol/compare/v5.0.1...v5.1.0) (2023-11-15)


### Features

* Made non-sa-auth possible with gcloud ([8104a24](https://github.com/dodevops/cloudcontrol/commit/8104a2449b869e3655a0e68969ccd0fecec2ed09))


### Bug Fixes

* Fixing typo in gcloud sample docker compose ([387ce06](https://github.com/dodevops/cloudcontrol/commit/387ce06e78fa625b65e2549b0baff23873b01eef))
* Fixing typo in google flavour init script ([252e0fd](https://github.com/dodevops/cloudcontrol/commit/252e0fd9721eb117f9ac1b2b30089cdc9357b537))
* Updating fisher installation command ([e85c473](https://github.com/dodevops/cloudcontrol/commit/e85c473de08d128fd6e3a65eb468b3e0f5e9f046))
* Updating fisher installation command ([922aa36](https://github.com/dodevops/cloudcontrol/commit/922aa36755d96f4f969dfc56ded57f06dba3d734))


### Documentation

* Added platform documentation ([5a412fb](https://github.com/dodevops/cloudcontrol/commit/5a412fbe24b64837c9cc504cdccdaf412c9ab2a6))
* Automatic docs update ([25c9776](https://github.com/dodevops/cloudcontrol/commit/25c9776530c6e2acbf3deb4564697b5cd011b6b0))
* Changed registry ([d63efb1](https://github.com/dodevops/cloudcontrol/commit/d63efb189b310d190a8bdc8bd2b9cf13ae269ea7))



## [4.4.0](https://github.com/dodevops/cloudcontrol/compare/v4.3.0...v4.4.0) (2023-06-01)


### Features

* Made non-sa-auth possible with gcloud ([8104a24](https://github.com/dodevops/cloudcontrol/commit/8104a2449b869e3655a0e68969ccd0fecec2ed09))


### Bug Fixes

* Fixing typo in gcloud sample docker compose ([387ce06](https://github.com/dodevops/cloudcontrol/commit/387ce06e78fa625b65e2549b0baff23873b01eef))
* Fixing typo in google flavour init script ([252e0fd](https://github.com/dodevops/cloudcontrol/commit/252e0fd9721eb117f9ac1b2b30089cdc9357b537))
* Updating fisher installation command ([e85c473](https://github.com/dodevops/cloudcontrol/commit/e85c473de08d128fd6e3a65eb468b3e0f5e9f046))
* Updating fisher installation command ([922aa36](https://github.com/dodevops/cloudcontrol/commit/922aa36755d96f4f969dfc56ded57f06dba3d734))


### Documentation

* Added platform documentation ([5a412fb](https://github.com/dodevops/cloudcontrol/commit/5a412fbe24b64837c9cc504cdccdaf412c9ab2a6))
* Automatic docs update ([25c9776](https://github.com/dodevops/cloudcontrol/commit/25c9776530c6e2acbf3deb4564697b5cd011b6b0))
* Changed registry ([d63efb1](https://github.com/dodevops/cloudcontrol/commit/d63efb189b310d190a8bdc8bd2b9cf13ae269ea7))



## [4.3.0](https://github.com/dodevops/cloudcontrol/compare/v4.2.0...v4.3.0) (2023-03-02)


### Features

* Added AWS test for kubernetes ([47b814d](https://github.com/dodevops/cloudcontrol/commit/47b814d039d20cc29603c71663bccf5a7338ffcc))
* Enables gcloud interactive login ([b8acacb](https://github.com/dodevops/cloudcontrol/commit/b8acacb2e8b5cca3077a3d0083f36fd67b314ec2))


### Documentation

* Fixes a missing environment documentation ([12d1f22](https://github.com/dodevops/cloudcontrol/commit/12d1f22809fd715104d6e67a2899b15d41fb5db5))
* Updated flavour/gcloud/flavour.yaml ([7532785](https://github.com/dodevops/cloudcontrol/commit/75327850278d892ff13b4daad8e08407329a3a35))
* Updated README ([c265ba9](https://github.com/dodevops/cloudcontrol/commit/c265ba96015235ea0a143224239755b7fcbc806e))
