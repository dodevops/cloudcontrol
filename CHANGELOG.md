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
