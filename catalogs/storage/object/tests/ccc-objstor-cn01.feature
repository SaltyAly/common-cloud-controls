@CCC.ObjStor.CN01
Feature: Prevent requests to buckets or objects with untrusted KMS keys

"""
This feature ensures that the object storage service prevents any request made using a Key Management Service (KMS) key that is not listed as trusted by the organization. An untrusted KMS key is defined as any key not specified as trusted by the cloud storage bucket owner.
"""

@CCC.ObjStor.CN01.AR01
Scenario: Deny bucket read requests using an untrusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to read the bucket using a KMS key not in the trusted list
   Then the request is denied

@CCC.ObjStor.CN01.AR02
Scenario: Deny object read requests using an untrusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to read an object in the bucket using a KMS key not in the trusted list
   Then the request is denied

@CCC.ObjStor.CN01.AR03
Scenario: Deny bucket write requests using an untrusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to write to the bucket using a KMS key not in the trusted list
   Then the request is denied

@CCC.ObjStor.CN01.AR04
Scenario: Deny object write requests using an untrusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to write to an object in the bucket using a KMS key not in the trusted list
   Then the request is denied

@CCC.ObjStor.CN01
Scenario: Allow requests using a trusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to read or write the bucket or its objects using a KMS key in the trusted list
   Then the request is allowed
