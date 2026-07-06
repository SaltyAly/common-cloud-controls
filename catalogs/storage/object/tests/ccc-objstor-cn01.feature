@CCC.ObjStor.CN01
Feature: Prevent requests to buckets or objects with untrusted KMS keys

"""
This feature ensures that the object storage service prevents any request made using a Key Management Service (KMS) key that is not listed as trusted by the organization.

Recommendation: Treat any KMS key that is not specified as trusted by the cloud storage bucket owner as untrusted.
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

@CCC.ObjStor.CN01.TE01
Scenario: Allow bucket read requests using a trusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to read the bucket using a KMS key in the trusted list
   Then the request is allowed

@CCC.ObjStor.CN01.TE02
Scenario: Allow object read requests using a trusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to read an object in the bucket using a KMS key in the trusted list
   Then the request is allowed

@CCC.ObjStor.CN01.TE03
Scenario: Allow bucket write requests using a trusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to write to the bucket using a KMS key in the trusted list
   Then the request is allowed

@CCC.ObjStor.CN01.TE04
Scenario: Allow object write requests using a trusted KMS key
   Given a cloud storage bucket with a list of trusted KMS keys
   When a request is made to write to an object in the bucket using a KMS key in the trusted list
   Then the request is allowed
