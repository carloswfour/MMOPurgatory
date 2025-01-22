CREATE TABLE [dbo].[GIS_ROMPad_DirectHaul] (
    [ObjectID]          INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [X]                 REAL            NOT NULL,
    [Y]                 REAL            NOT NULL,
    [Z]                 REAL            NOT NULL,
    [DUMPTIME]          DATETIME        NULL,
    [START_SHIFT_DATE]  DATETIME        NOT NULL,
    [LOAD_SNAME]        VARCHAR (24)    NULL,
    [BLOCK_SNAME]       VARCHAR (24)    NULL,
    [DUMP_LOC]          VARCHAR (24)    NULL,
    [HAUL_CYCLE_REC_ID] NUMERIC (9)     NOT NULL,
    [HAULUNIT]          VARCHAR (6)     NOT NULL,
    [LOADUNIT]          VARCHAR (6)     NULL,
    [MATIDENT]          VARCHAR (3)     NULL,
    [MATDESC]           VARCHAR (35)    NOT NULL,
    [QUANTITY]          NUMERIC (14, 4) NOT NULL,
    [Ni]                FLOAT (53)      NULL,
    [Co]                FLOAT (53)      NULL,
    [Cl]                FLOAT (53)      NULL,
    CONSTRAINT [PK_DirHaulObjID] PRIMARY KEY CLUSTERED ([ObjectID] ASC)
);

