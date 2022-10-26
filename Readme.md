
# Using Sops

___
Resource: [SOPS github](https://github.com/mozilla/sops#encrypting-using-gcp-kms)

[Terraform provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
___

# Setup

___

### Variables

I have tried my best to create consistent variables that can be searched and replaced for the entire project.

|Variable|Purpose|
|--------|-------|
|<PROJECT_NAME>|Google Cloud project ID name|
|<KR_NAME>|The Key Ring you create|
|<KEY_NAME>|A Specific key that lives in a key ring|
___


You need to at least have access to a Google Cloud project that can create key-rings and tokens.

On your local machine authenticate to Google Cloud

```
gcloud auth login
```

Make sure you are on the correct project

```
gcloud config set project <project_ID>
```

You can list your projects with

```
gcloud projects list
```

You will have to have a key available or create your own via terraform. I have created some terraform that will create a key-ring as well as some keys to use with this [Github Link](https://github.com/MarkDPierce/MDP-GCP-Tokens)

## Terraform Setup
There are some terraform files that are designed to help create an example setup to help follow along. Just be aware that when you create a KeyRing, you can not delete it unless you delete the project. The terraform is setup to use a `.tfvars` file that has a space for "creds" this should be a service account's json file for authentication.

To list available keys that have been created. Just replace `<KR_NAME>` with your own Key-ring's name

```
gcloud kms keys list --location global --keyring <KR_NAME>
```

In `sops/Demo` there should already be a file called `secrets.yaml` that contains some unencrypted YAML that you can use to encrypt.  In the `sops/Demo2` directory there is also a secrets file and a `.sops.yaml` file. The .sops file is used as another [example](#the-sopsyaml-file) of refrencing tokens for encryption.

And just create a simple token you would like to encrypt

```yaml
api_tokens:
  token_foo: FFFFFFooooooooooooBBBBBBBBBBaaaaaaaaaaaaRRRRRRR
```

### Encrypt the file in place

To encrypt a file in place, meaning you take a normal file and replace its contents with the encrypted data.

```
sops --encrypt --in-place --gcp-kms projects/mdp-token/locations/global/keyRings/mdpeys/cryptoKeys/demo-key secrets.yaml
```

##### The .sops.yaml file

It is also possible to create a `.sops.yaml` file that hosts the GCP-KMS information instead of having to type it or constantly feed it and the format should look like the following.

Just replace `<PROJECT_NAME>` with your Google Cloud Project Name. Change `<KR_NAME>` with the correct name of your Google Cloud key-ring and replace `<KEY_NAME>` with the name of the key you will be using for this demo.

```yaml
---
creation_rules:
       # Encrypt using GCP KMS
       - gcp_kms: projects/<PROJECT_NAME>/locations/global/keyRings/<KR_NAME>/cryptoKeys/<KEY_NAME>
```

### Decrypt

To Decrypt the file in place. You do not need to provide the cloud project that holds the key. This information is part of the encrypted file and is used when `--decrypt` is flagged.

```
sops --decrypt --in-place secrets.yaml
```

## Rolling tokens

___

[Reference Doc](https://cloud.google.com/kms/docs/re-encrypt-data)

**Workflow**

* Decrypt data using prior key version
* Encrypt data using new primary key
* Disable or schedule destruction of old key

### Decrypt with Pending deletion token

___

1. I created a key
2. Encrypted `secrets.yaml` with the key
3. I then deleted the key (click-ops) and will attempt to decrypt `secrets.yaml`.
`sops -d -i secrets.yaml`

```shell
Failed to get the data key required to decrypt the SOPS file.

Group 0: FAILED
  projects/mdp-token/locations/global/keyRings/mdpeys/cryptoKeys/demo-key-roller: FAILED
    - | Error decrypting key: googleapi: Error 400:
      | projects/mdp-token/locations/global/keyRings/mdpeys/cryptoKeys/demo-key-roller/cryptoKeyVersions/1
      | is not enabled, current state is: DESTROY_SCHEDULED.
      | Details:
      | [
      |   {
      |     "@type":
      | "type.googleapis.com/google.rpc.PreconditionFailure",
      |     "violations": [
      |       {
      |         "subject":
      | "projects/mdp-token/locations/global/keyRings/mdpeys/cryptoKeys/demo-key-roller/cryptoKeyVersions/1",
      |         "type": "KEY_DESTROY_SCHEDULED"
      |       }
      |     ]
      |   }
      | ]
      | , failedPrecondition

Recovery failed because no master key was able to decrypt the file. In
order for SOPS to recover the file, at least one key has to be successful,
but none were.
```

This is due to when encryption keys are deleted, they are disabled and placed in a bucket for 24 hours before being purged from google cloud. At this point you can not use the key to encrypt/decrypt data. However it is possible to restore the pending removal key and use it to encrypt/decrypt.

### Encrypt with Pending deletion token

___
If you try to encrypt with a token that does not exist you get the following error.

```shell
Could not generate data key: [failed to encrypt new data key with master key "projects/mdp-token/locations/global/keyRings/mdpeys/cryptoKeys/demo-key": Failed to call GCP KMS encryption service: googleapi: Error 400: projects/mdp-token/locations/global/keyRings/mdpeys/cryptoKeys/demo-key/cryptoKeyVersions/1 is not enabled, current state is: DESTROY_SCHEDULED.
Details:
[
  {
    "@type": "type.googleapis.com/google.rpc.PreconditionFailure",
    "violations": [
      {
        "subject": "projects/mdp-token/locations/global/keyRings/mdpeys/cryptoKeys/demo-key/cryptoKeyVersions/1",
        "type": "KEY_DESTROY_SCHEDULED"
      }
    ]
  }
]
, failedPrecondition]
```
