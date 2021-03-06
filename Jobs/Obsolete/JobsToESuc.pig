REGISTER '/usr/lib/pig/piggybank.jar' ;
REGISTER '/usr/lib/pig/lib/avro-*.jar';
REGISTER '/usr/lib/pig/lib/jackson-*.jar';
REGISTER '/usr/lib/pig/lib/json-*.jar';
REGISTER '/usr/lib/pig/lib/jython-*.jar';
REGISTER '/usr/lib/pig/lib/snappy-*.jar';

REGISTER '/elasticsearch-hadoop/elasticsearch-hadoop-pig.jar';

REGISTER 'myudfs.py' using jython as myfuncs;

SET default_parallel 5;
SET pig.noSplitCombination FALSE;

define EsStorage org.elasticsearch.hadoop.pig.EsStorage(
    'es.nodes=http://es-head01.mwt2.org,http://es-head02.mwt2.org,http://es-head03.mwt2.org',
    'es.port=9200',
    'es.mapping.id=pandaid',
    'es.http.timeout=5m',
    'es.batch.size.entries=10000'
    );


PAN = LOAD '/atlas/analytics/jobs_temp' USING AvroStorage();
--DESCRIBE PAN;

--L = LIMIT PAN 1000; --dump L;

REC = FOREACH PAN GENERATE PANDAID as pandaid, JOBDEFINITIONID as jobdefinitionid, SCHEDULERID as schedulerid, PILOTID as pilotid, REPLACE(CREATIONTIME,' ','T') as creationtime, CREATIONHOST as creationhost, REPLACE(MODIFICATIONTIME,' ','T') as modificationtime, MODIFICATIONHOST as modificationhost, ATLASRELEASE as atlasrelease, TRANSFORMATION as transformation, HOMEPACKAGE as homepackage, PRODSERIESLABEL as prodserieslabel, PRODSOURCELABEL as prodsourcelabel, PRODUSERID as produserid, ASSIGNEDPRIORITY as assignedpriority, CURRENTPRIORITY as currentpriority, ATTEMPTNR as attemptnr, MAXATTEMPT as maxattempt, JOBSTATUS as jobstatus, JOBNAME as jobname, MAXCPUCOUNT as maxcpucount, MAXDISKCOUNT as maxdiskcount, MINRAMCOUNT as minramcount, REPLACE(STARTTIME,' ','T') as starttime, REPLACE(ENDTIME,' ','T') as endtime, (int)CPUCONSUMPTIONTIME as cpuconsumptiontime, CPUCONSUMPTIONUNIT as cpuconsumptionunit, COMMANDTOPILOT as commandtopilot, TRANSEXITCODE as transexitcode, PILOTERRORCODE as piloterrorcode, PILOTERRORDIAG as piloterrordiag, EXEERRORCODE as exeerrorcode, EXEERRORDIAG as exeerrordiag, SUPERRORCODE as superrorcode, SUPERRORDIAG as superrordiag, DDMERRORCODE as ddmerrorcode, DDMERRORDIAG as ddmerrordiag, BROKERAGEERRORCODE as brokerageerrorcode, BROKERAGEERRORDIAG as brokerageerrordiag, JOBDISPATCHERERRORCODE as jobdispatchererrorcode, JOBDISPATCHERERRORDIAG as jobdispatchererrordiag, TASKBUFFERERRORCODE as taskbuffererrorcode, TASKBUFFERERRORDIAG as taskbuffererrordiag, COMPUTINGSITE as computingsite, COMPUTINGELEMENT as computingelement, PRODDBLOCK as proddblock, DISPATCHDBLOCK as dispatchdblock, DESTINATIONDBLOCK as destinationdblock, DESTINATIONSE as destinationse, NEVENTS as nevents, GRID as grid, CLOUD as cloud, CPUCONVERSION as cpuconversion, SOURCESITE as sourcesite, DESTINATIONSITE as destinationsite, TRANSFERTYPE as transfertype, TASKID as taskid, CMTCONFIG as cmtconfig,REPLACE(STATECHANGETIME,' ','T') as statechangetime, LOCKEDBY as lockedby, RELOCATIONFLAG as relocationflag, JOBEXECUTIONID as jobexecutionid, VO as vo, WORKINGGROUP as workinggroup, PROCESSINGTYPE as processingtype, PRODUSERNAME as produsername, COUNTRYGROUP as countrygroup, BATCHID as batchid, PARENTID as parentid, SPECIALHANDLING as specialhandling, JOBSETID as jobsetid, CORECOUNT as corecount, NINPUTDATAFILES as ninputdatafiles, INPUTFILETYPE as inputfiletype, INPUTFILEPROJECT as inputfileproject, INPUTFILEBYTES as inputfilebytes, NOUTPUTDATAFILES as noutputdatafiles, OUTPUTFILEBYTES as outputfilebytes, FLATTEN(myfuncs.splitJobmetrics(JOBMETRICS)) as (dbTime:float, dbData:long, workDirSize:long, jobmetrics:chararray), WORKQUEUE_ID as workqueue_id, JEDITASKID as jeditaskid, JOBSUBSTATUS as jobsubstatus, ACTUALCORECOUNT as actualcorecount, REQID as reqid, MAXRSS as maxrss, MAXVMEM as maxvmem, MAXPSS as maxpss, AVGRSS as avgrss, AVGVMEM as avgvmem, AVGSWAP as avgswap, AVGPSS as avgpss, MAXWALLTIME as maxwalltime, FLATTEN(myfuncs.deriveDurationAndCPUeffNEW(CREATIONTIME,STARTTIME,ENDTIME,CPUCONSUMPTIONTIME)) as (wall_time:int, cpu_eff:float, queue_time:int), FLATTEN(myfuncs.deriveTimes(PILOTTIMING)) as (timeGetJob:int, timeStageIn:int, timeExe:int, timeStageOut:int, timeSetup:int), NUCLEUS as nucleus, EVENTSERVICE as eventservice, FAILEDATTEMPT as failedattempt, HS06SEC as hs06sec, HS06 as hs06, GSHARE as gShare, TOTRCHAR as IOcharRead, TOTWCHAR as IOcharWritten, TOTRBYTES as IObytesRead, TOTWBYTES as IObytesWritten, RATERCHAR as IOcharReadRate, RATEWCHAR as IOcharWriteRate, RATERBYTES as IObytesReadRate, RATEWBYTES as IObytesWriteRate;

STORE REC INTO 'jobs_archive_$ININD/jobs_data' USING EsStorage();