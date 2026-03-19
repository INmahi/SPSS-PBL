* Encoding: UTF-8.
INPUT PROGRAM.
loop student_id = 1 to 649.
END CASE.
END LOOP.
END FILE.
END INPUT PROGRAM.
EXECUTE.

*as we will generate either 1 or 0 as values, we will use Bernouli with probabilty of 1 as argument.
COMPUTE scholarship_status = RV.BERNOULLI(0.56).
EXECUTE.

* for the socialMediaEngagement variable we need 4 integers from 1 to 4 . we use RND to round the random deciaml point numbers into integers.
COMPUTE socialMediaEngagement = RND(RV.UNIFORM(1,4)).
EXECUTE.

