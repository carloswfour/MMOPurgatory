CREATE TABLE [dbo].[Z_LOCAL_TRANSFORM_COEFFICIENTS] (
    [ProjArea]  NVARCHAR (10) NULL,
    [A1]        FLOAT (53)    NULL,
    [A2]        FLOAT (53)    NULL,
    [A3]        FLOAT (53)    NULL,
    [B1]        FLOAT (53)    NULL,
    [B2]        FLOAT (53)    NULL,
    [B3]        FLOAT (53)    NULL,
    [ProjectID] INT           NULL,
    [CoeffID]   INT           NOT NULL
);

