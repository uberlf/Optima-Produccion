
ALTER TABLE Commodity ADD GTINCode VARCHAR(20) NULL
_GO_
ALTER TABLE CommStyle ADD GTINCode VARCHAR(20) NULL
_GO_
ALTER TABLE CommVariety ADD GTINCode VARCHAR(20) NULL
_GO_
ALTER TABLE CommSize ADD GTINCode VARCHAR(20) NULL
_GO_

CREATE FUNCTION dbo.fGTINCode(@GTINCodeSz VARCHAR(20),  @GTINCodeSt VARCHAR(20), @GTINCodeVa VARCHAR(20), @GTINCodeCo VARCHAR(20), @GTINCodeDist VARCHAR(20))
RETURNS VARCHAR(20)
AS
BEGIN
   DECLARE @GTINCode VARCHAR(20)
   SET @GTINCode = CASE WHEN NOT LEN(ISNULL(@GTINCodeSz, '')) = 0 THEN @GTINCodeSz
								 		ELSE
											CASE WHEN NOT LEN(ISNULL(@GTINCodeSt, '')) = 0 THEN @GTINCodeSt
											 ELSE
												 CASE WHEN NOT LEN(ISNULL(@GTINCodeVa, '')) = 0 THEN @GTINCodeVa
												  ELSE
														CASE WHEN NOT LEN(ISNULL(@GTINCodeCo, '')) = 0 THEN @GTINCodeCo
														 ELSE
															CASE WHEN NOT LEN(ISNULL(@GTINCodeDist, '')) = 0 THEN @GTINCodeDist
															ELSE
															 ''
															END
														END
												 END
											END
									 END
  
   
   RETURN(@GTINCode)

END

_GO_

ALTER PROCEDURE [dbo].[CommodityAdd]
@CommodityID		int,
@CommDesc		varchar(60),
@CommEnDesc		varchar(60),
@CommShDesc		varchar(60),
@MaturityDays	smallint,
@NoDependants	bit,
@NoActive		bit,
@UpDatedByID		int,
@OrderKey		varchar(3),
@OriginalVersion	VARCHAR(100),
@GTINDescription	VARCHAR(20) = NULL,
@GTINCode VARCHAR(20) = NULL

AS

DECLARE
@Result BIT

BEGIN TRANSACTION

--Si es nuevo registro, pero el nombre ya lo registro otro usuario
IF @CommodityID = -1 OR @CommodityID = 0
BEGIN
	SET @CommodityID = ISNULL((SELECT CommodityID FROM Commodity WHERE CommDesc = @CommDesc), @CommodityID)
END

IF (SELECT COUNT(*) AS REGS FROM Commodity
	WHERE CommodityID = @CommodityID) = 0
	BEGIN
		SET @Result = 1
		
		INSERT INTO Commodity(CommDesc, CommEnDesc, CommShDesc, MaturityDays, NoDependants, 
							  NoActive, LastUpDated, UpDatedByID, OrderKey, GTINDescription, GTINCode)
					VALUES(@CommDesc, @CommEnDesc, @CommShDesc, @MaturityDays, @NoDependants, 
							  @NoActive, GETDATE(), @UpDatedByID, @OrderKey, @GTINDescription, @GTINCode)
							  
		SET @CommodityID = SCOPE_IDENTITY()
	END
	
	ELSE
	BEGIN
	
	IF NOT (SELECT COUNT(*) AS REGS FROM Commodity
	WHERE  CommodityID = @CommodityID AND
			OriginalVersion = CONVERT(TimeStamp, @OriginalVersion)) = 0
		BEGIN   
		
			UPDATE Commodity SET
				CommDesc	=	@CommDesc, 
				CommEnDesc	=	@CommEnDesc, 
				CommShDesc	=	@CommShDesc, 
				MaturityDays	=	@MaturityDays, 
				NoDependants	=	@NoDependants, 
				NoActive	=	@NoActive, 
				LastUpDated	=	GETDATE(), 
				UpDatedByID	=	@UpDatedByID, 
				OrderKey	=	@OrderKey,
				GTINDescription	=	@GTINDescription,
				GTINCode	=	@GTINCode
			WHERE CommodityID = @CommodityID
		
			SET @Result = 1
		END
		ELSE
		BEGIN	
			SET @Result = 0
		END
		
	END
	
	
	SELECT CommodityID, CONVERT(VARCHAR, OriginalVersion) AS OriginalVersion FROM Commodity
	WHERE CommodityID = @CommodityID
	
	SELECT @Result AS Result
 
	SELECT U.*, C.LastUpDated AS LastUpdateUser
		FROM Commodity AS C 
			INNER JOIN Users AS U ON
				U.UserID	=	C.UpDatedByID
			WHERE  CommodityID = @CommodityID 
	
	
	
IF (SELECT @@error) = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION

_GO_

ALTER PROCEDURE [dbo].[CommodityFirst]

AS
	
SELECT TOP 1 CommodityID, CommDesc, CommEnDesc, CommShDesc, MaturityDays, NoDependants,
		NoActive, LastUpDated, UpDatedByID, OrderKey, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINDescription, '') AS GTINDescription,
		ISNULL(GTINCode, '') AS GTINCode
 FROM Commodity	
ORDER BY CommodityID ASC

_GO_

ALTER PROCEDURE [dbo].[CommodityGetByDesc]
@CommDesc	VARCHAR(60)
AS
	
SELECT CommodityID, CommDesc, CommEnDesc, CommShDesc, MaturityDays, NoDependants,
		NoActive, LastUpDated, UpDatedByID, OrderKey, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINDescription, '') AS GTINDescription,
		ISNULL(GTINCode, '') AS GTINCode
 FROM Commodity	
WHERE CommDesc = @CommDesc

_GO_

ALTER PROCEDURE [dbo].[CommodityGetByID]
@CommodityID	INT
AS
	
SELECT CommodityID, CommDesc, CommEnDesc, CommShDesc, MaturityDays, NoDependants,
		NoActive, LastUpDated, UpDatedByID, OrderKey, 
		CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINDescription, '') AS GTINDescription,
		ISNULL(GTINCode, '') AS GTINCode 
 FROM Commodity	
WHERE CommodityID = @CommodityID

_GO_

ALTER PROCEDURE [dbo].[CommodityLast]

AS
	
SELECT TOP 1 CommodityID, CommDesc, CommEnDesc, CommShDesc, MaturityDays, NoDependants,
		NoActive, LastUpDated, UpDatedByID, OrderKey, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINDescription, '') AS GTINDescription,
		ISNULL(GTINCode, '') AS GTINCode 
 FROM Commodity	
ORDER BY CommodityID DESC

_GO_

ALTER PROCEDURE [dbo].[CommodityNext]
@CommodityID	INT
AS
	
SELECT TOP 1 CommodityID, CommDesc, CommEnDesc, CommShDesc, MaturityDays, NoDependants,
		NoActive, LastUpDated, UpDatedByID, OrderKey, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINDescription, '') AS GTINDescription,
		ISNULL(GTINCode, '') AS GTINCode 
 FROM Commodity	
WHERE CommodityID > @CommodityID
ORDER BY CommodityID ASC

_GO_


ALTER PROCEDURE [dbo].[CommodityPrevious]
@CommodityID	INT
AS
	
SELECT TOP 1 CommodityID, CommDesc, CommEnDesc, CommShDesc, MaturityDays, NoDependants,
		NoActive, LastUpDated, UpDatedByID, OrderKey, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINDescription, '') AS GTINDescription,
		ISNULL(GTINCode, '') AS GTINCode 
 FROM Commodity	
WHERE CommodityID < @CommodityID
ORDER BY CommodityID DESC

_GO_

ALTER PROCEDURE [dbo].[CommVarietyAdd]
@VarietyID		int,
@CommodityID	int,
@VarDesc		varchar(60),
@VarEnDesc		varchar(60),
@VarShDesc		varchar(60),
@FormatID		int,
@MaintainTemHi	int,
@MantainTempLo	int,
@HarvestDays	int,
@NoDependants	bit,
@NoActive		bit,
@UpDatedByID	int,
@OrderKey		varchar(3),
@GTINDescription	varchar(20) = NULL,
@GTINCode VARCHAR(20) = NULL

AS

IF (SELECT COUNT(*) AS REGS FROM CommVariety
	WHERE CommodityID	= @CommodityID AND
		  VarietyID		= @VarietyID) = 0
BEGIN
		INSERT INTO CommVariety(CommodityID, VarDesc, VarEnDesc, VarShDesc, FormatID, MaintainTemHi,
								MantainTempLo, HarvestDays, NoDependants, NoActive, LastUpDated, UpDatedByID,
								OrderKey, GTINDescription, GTINCode)
						VALUES(@CommodityID, @VarDesc, @VarEnDesc, @VarShDesc, @FormatID, @MaintainTemHi,
								@MantainTempLo, @HarvestDays, @NoDependants, @NoActive, GETDATE(), @UpDatedByID,
								@OrderKey, @GTINDescription, @GTINCode)
								
		SET @VarietyID = SCOPE_IDENTITY()
END
ELSE
BEGIN
	UPDATE CommVariety SET				
		VarDesc			=	@VarDesc,
		VarEnDesc		=	@VarEnDesc,
		VarShDesc		=	@VarShDesc,
		FormatID		=	@FormatID,
		MaintainTemHi	=	@MaintainTemHi,
		MantainTempLo	=	@MantainTempLo,
		HarvestDays		=	@HarvestDays,
		NoDependants	=	@NoDependants,
		NoActive		=	@NoActive,
		LastUpDated		=	GETDATE(),
		UpDatedByID		=	@UpDatedByID,
		OrderKey		=	@OrderKey,
		GTINDescription	=	@GTINDescription,
		GTINCode	=	@GTINCode
	WHERE CommodityID	= @CommodityID AND
		  VarietyID		= @VarietyID	
END

SELECT @VarietyID AS VarietyID

_GO_

ALTER PROCEDURE [dbo].[CommVarietyFirst]
@CommodityID	INT
AS
	
SELECT TOP 1 C.CommodityID, CommDesc, VarDesc, VarietyID, VarEnDesc, VarShDesc, FormatID, MaintainTemHi, MantainTempLo, HarvestDays,
		V.NoDependants, V.NoActive, V.LastUpDated, V.UpDatedByID, V.OrderKey, 
		CONVERT(VARCHAR, V.OriginalVersion) AS OriginalVersion,
		ISNULL(V.GTINDescription, '') AS GTINDescription,
		ISNULL(V.GTINCode, '') AS GTINCode
 FROM CommVariety AS V
		INNER JOIN Commodity AS C ON
			C.CommodityID = V.CommodityID
 WHERE V.CommodityID = @CommodityID
ORDER BY VarietyID ASC

_GO_

ALTER PROCEDURE [dbo].[CommVarietyGetByDescription]
@CommodityID	INT,
@VarDesc		VARCHAR(60)
AS

SELECT C.CommodityID, CommDesc, VarDesc, VarietyID, VarEnDesc, VarShDesc, FormatID, MaintainTemHi, MantainTempLo, HarvestDays,
		V.NoDependants, V.NoActive, V.LastUpDated, V.UpDatedByID, V.OrderKey, CONVERT(VARCHAR, V.OriginalVersion) AS OriginalVersion,
		ISNULL(V.GTINDescription, '') AS GTINDescription,
		ISNULL(V.GTINCode, '') AS GTINCode
		FROM CommVariety AS V
		INNER JOIN Commodity AS C ON
			C.CommodityID = V.CommodityID
WHERE V.CommodityID	=	@CommodityID	AND
	  VarDesc		=	@VarDesc

_GO_

ALTER PROCEDURE [dbo].[CommVarietyGetByID]
@VarietyID	INT
AS

SELECT C.CommodityID, CommDesc, VarDesc, VarietyID, VarEnDesc, VarShDesc, FormatID, MaintainTemHi, MantainTempLo, HarvestDays,
		V.NoDependants, V.NoActive, V.LastUpDated, V.UpDatedByID, V.OrderKey, 		
		CONVERT(VARCHAR, V.OriginalVersion) as OriginalVersion,
		ISNULL(V.GTINDescription, '') AS GTINDescription,
		ISNULL(V.GTINCode, '') AS GTINCode
		FROM CommVariety AS V
		INNER JOIN Commodity AS C ON
			C.CommodityID = V.CommodityID
WHERE VarietyID = @VarietyID

_GO_


ALTER PROCEDURE [dbo].[CommVarietyLast]
@CommodityID	INT
AS
	
SELECT TOP 1 C.CommodityID, CommDesc, VarDesc, VarietyID, VarEnDesc, VarShDesc, FormatID, MaintainTemHi, MantainTempLo, HarvestDays,
		V.NoDependants, V.NoActive, V.LastUpDated, V.UpDatedByID, V.OrderKey, CONVERT(VARCHAR, V.OriginalVersion) AS OriginalVersion,
		ISNULL(V.GTINDescription, '') AS GTINDescription,
		ISNULL(V.GTINCode, '') AS GTINCode
FROM CommVariety AS V
		INNER JOIN Commodity AS C ON
			C.CommodityID = V.CommodityID
 WHERE V.CommodityID = @CommodityID
ORDER BY VarietyID DESC

_GO_


ALTER PROCEDURE [dbo].[CommVarietyNext]
@CommodityID	INT,
@VarietyID		INT
AS
	
SELECT TOP 1 C.CommodityID, CommDesc, VarDesc, VarietyID, VarEnDesc, VarShDesc, FormatID, MaintainTemHi, MantainTempLo, HarvestDays,
		V.NoDependants, V.NoActive, V.LastUpDated, V.UpDatedByID, V.OrderKey, CONVERT(VARCHAR, V.OriginalVersion) AS OriginalVersion,
		ISNULL(V.GTINDescription, '') AS GTINDescription,
		ISNULL(V.GTINCode, '') AS GTINCode
 FROM CommVariety AS V
		INNER JOIN Commodity AS C ON
			C.CommodityID = V.CommodityID
 WHERE V.CommodityID = @CommodityID AND
		VarietyID	>	@VarietyID
ORDER BY VarietyID ASC

_GO_


ALTER PROCEDURE [dbo].[CommVarietyPrevious]
@CommodityID	INT,
@VarietyID		INT
AS
	
SELECT TOP 1 C.CommodityID, CommDesc, VarDesc, VarietyID, VarEnDesc, VarShDesc, FormatID, MaintainTemHi, MantainTempLo, HarvestDays,
		V.NoDependants, V.NoActive, V.LastUpDated, V.UpDatedByID, V.OrderKey, CONVERT(VARCHAR, V.OriginalVersion) AS OriginalVersion,
		ISNULL(V.GTINDescription, '') AS GTINDescription,
		ISNULL(V.GTINCode, '') AS GTINCode
 FROM CommVariety AS V
		INNER JOIN Commodity AS C ON
			C.CommodityID = V.CommodityID
 WHERE V.CommodityID = @CommodityID AND
		VarietyID	<	@VarietyID
ORDER BY VarietyID DESC

_GO_


ALTER PROCEDURE [dbo].[CommStyleAdd]
@StyleID		int,
@VarietyID		int,
@StyleDesc		varchar(60),
@StyleEnDesc	varchar(60),
@StyleShDesc	varchar(60),
@BoxNetWt		int,
@BoxTareWt		int,
@PalletQty		int,
@NoDependants	bit,
@NoActive		bit,
@UpDatedByID	int,
@OrderKey		varchar(3),
@BoxQty			int,	
@GTINDescription	varchar(20) = NULL,
@ImprimirEtiquetasChicas	BIT = NULL,
@GTINCode VARCHAR(20)

AS

IF (SELECT COUNT(*) AS REGS FROM CommStyle
	WHERE StyleID	= @StyleID AND
		  VarietyID		= @VarietyID) = 0
BEGIN
		INSERT INTO CommStyle(VarietyID, StyleDesc, StyleEnDesc, StyleShDesc, BoxNetWt, BoxTareWt,
								PalletQty, NoDependants, NoActive, LastUpDated, UpDatedByID, OrderKey,
								BoxQty, GTINDescription, ImprimirEtiquetasChicas, GTINCode)
						VALUES(@VarietyID, @StyleDesc, @StyleEnDesc, @StyleShDesc, @BoxNetWt, @BoxTareWt,
								@PalletQty, @NoDependants, @NoActive, GETDATE(), @UpDatedByID, @OrderKey,
								@BoxQty, @GTINDescription, @ImprimirEtiquetasChicas, @GTINCode)
								
		SET @StyleID = SCOPE_IDENTITY()
END
ELSE
BEGIN
	UPDATE CommStyle SET				
		VarietyID	=	@VarietyID, 
		StyleDesc	=	@StyleDesc, 
		StyleEnDesc	=	@StyleEnDesc, 
		StyleShDesc	=	@StyleShDesc, 
		BoxNetWt	=	@BoxNetWt, 
		BoxTareWt	=	@BoxTareWt,
		PalletQty	=	@PalletQty, 
		NoDependants	=	@NoDependants, 
		NoActive	=	@NoActive, 
		LastUpDated	=	GETDATE(), 
		UpDatedByID	=	@UpDatedByID, 
		OrderKey	=	@OrderKey,
		BoxQty		=	@BoxQty,
		GTINDescription	=	@GTINDescription,
		ImprimirEtiquetasChicas	=	@ImprimirEtiquetasChicas,
		GTINCode	=	@GTINCode
	WHERE StyleID		= @StyleID AND
		  VarietyID		= @VarietyID
END

SELECT @StyleID AS StyleID

_GO_

ALTER PROCEDURE [dbo].[CommStyleFirst]
@CommodityID	INT,
@VarietyID		INT
AS
	
SELECT TOP 1 S.StyleID, S.VarietyID, S.StyleDesc, S.StyleEnDesc, S.StyleShDesc, S.BoxNetWt, S.BoxTareWt, S.PalletQty, S.NoDependants,
		S.NoActive, S.LastUpDated, S.UpDatedByID, S.OrderKey, 
		CONVERT(VARCHAR, S.OriginalVersion) as OriginalVersion, S.BoxQty,
		V.VarDesc, V.CommodityID, C.CommDesc,
		ISNULL(S.GTINDescription, '') AS GTINDescription,
		ISNULL(ImprimirEtiquetasChicas, 0) AS ImprimirEtiquetasChicas,
		ISNULL(S.GTINCode, '') AS GTINCode
		FROM CommStyle AS S
			INNER JOIN CommVariety AS V ON
				V.VarietyID = S.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID = V.CommodityID
 WHERE C.CommodityID	=	@CommodityID	AND
	   S.VarietyID		=	@VarietyID
ORDER BY StyleID ASC

_GO_

ALTER PROCEDURE [dbo].[CommStyleGetByDescription]
@CommodityID	INT,
@VarietyID		INT,
@StyleDesc		VARCHAR(80)
AS

SELECT S.StyleID, S.VarietyID, S.StyleDesc, S.StyleEnDesc, S.StyleShDesc, S.BoxNetWt, S.BoxTareWt, S.PalletQty, S.NoDependants,
		S.NoActive, S.LastUpDated, S.UpDatedByID, S.OrderKey, CONVERT(VARCHAR, S.OriginalVersion) as OriginalVersion,
		 S.BoxQty,
		V.VarDesc, V.CommodityID, C.CommDesc,
		ISNULL(S.GTINDescription, '') AS GTINDescription,
		ISNULL(ImprimirEtiquetasChicas, 0) AS ImprimirEtiquetasChicas,
		ISNULL(S.GTINCode, '') AS GTINCode
		FROM CommStyle AS S
			INNER JOIN CommVariety AS V ON
				V.VarietyID = S.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID = V.CommodityID
WHERE C.CommodityID	=	@CommodityID	AND
	  S.VarietyID	=	@VarietyID	AND
	  StyleDesc		=	@StyleDesc

_GO_



ALTER PROCEDURE [dbo].[CommStyleGetByID]
@StyleID	INT
AS

SELECT S.StyleID, S.VarietyID, S.StyleDesc, S.StyleEnDesc, S.StyleShDesc, S.BoxNetWt, S.BoxTareWt, S.PalletQty, S.NoDependants,
		S.NoActive, S.LastUpDated, S.UpDatedByID, S.OrderKey, CONVERT(VARCHAR, S.OriginalVersion) as OriginalVersion, S.BoxQty,
		V.VarDesc, V.CommodityID, C.CommDesc,
		ISNULL(S.GTINDescription, '') AS GTINDescription,
		ISNULL(ImprimirEtiquetasChicas, 0) AS ImprimirEtiquetasChicas,
		ISNULL(S.GTINCode, '') AS GTINCode
		FROM CommStyle AS S
			INNER JOIN CommVariety AS V ON
				V.VarietyID = S.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID = V.CommodityID
WHERE StyleID = @StyleID

_GO_

ALTER PROCEDURE [dbo].[CommStyleLast]
@CommodityID	INT,
@VarietyID		INT
AS
	
SELECT TOP 1 S.StyleID, S.VarietyID, S.StyleDesc, S.StyleEnDesc, S.StyleShDesc, S.BoxNetWt, S.BoxTareWt, S.PalletQty, S.NoDependants,
		S.NoActive, S.LastUpDated, S.UpDatedByID, S.OrderKey, CONVERT(VARCHAR, S.OriginalVersion) as OriginalVersion, S.BoxQty,
		V.VarDesc, V.CommodityID, C.CommDesc,
		ISNULL(S.GTINDescription, '') AS GTINDescription,
		ISNULL(ImprimirEtiquetasChicas, 0) AS ImprimirEtiquetasChicas,
		ISNULL(S.GTINCode, '') AS GTINCode
		FROM CommStyle AS S
			INNER JOIN CommVariety AS V ON
				V.VarietyID = S.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID = V.CommodityID
 WHERE C.CommodityID	=	@CommodityID	AND
	   S.VarietyID		=	@VarietyID
ORDER BY StyleID DESC

_GO_

ALTER PROCEDURE [dbo].[CommStyleNext]
@CommodityID	INT,
@VarietyID		INT,
@StyleID		INT
AS
	
SELECT TOP 1 S.StyleID, S.VarietyID, S.StyleDesc, S.StyleEnDesc, S.StyleShDesc, S.BoxNetWt, S.BoxTareWt, S.PalletQty, S.NoDependants,
		S.NoActive, S.LastUpDated, S.UpDatedByID, S.OrderKey, CONVERT(VARCHAR, S.OriginalVersion) as OriginalVersion, S.BoxQty,
		V.VarDesc, V.CommodityID, C.CommDesc,
		ISNULL(S.GTINDescription, '') AS GTINDescription,
		ISNULL(ImprimirEtiquetasChicas, 0) AS ImprimirEtiquetasChicas,
		ISNULL(S.GTINCode, '') AS GTINCode
		FROM CommStyle AS S
			INNER JOIN CommVariety AS V ON
				V.VarietyID = S.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID = V.CommodityID
 WHERE C.CommodityID	=	@CommodityID	AND
	   S.VarietyID		=	@VarietyID	AND 
	   StyleID			>	@StyleID
ORDER BY StyleID ASC

_GO_

ALTER PROCEDURE [dbo].[CommStylePrevious]
@CommodityID	INT,
@VarietyID		INT,
@StyleID		INT
AS
	
SELECT TOP 1 S.StyleID, S.VarietyID, S.StyleDesc, S.StyleEnDesc, S.StyleShDesc, S.BoxNetWt, S.BoxTareWt, S.PalletQty, S.NoDependants,
		S.NoActive, S.LastUpDated, S.UpDatedByID, S.OrderKey, CONVERT(VARCHAR, S.OriginalVersion) as OriginalVersion, S.BoxQty,
		V.VarDesc, V.CommodityID, C.CommDesc,
		ISNULL(S.GTINDescription, '') AS GTINDescription,
		ISNULL(ImprimirEtiquetasChicas, 0) AS ImprimirEtiquetasChicas,
		ISNULL(S.GTINCode, '') AS GTINCode
		FROM CommStyle AS S
			INNER JOIN CommVariety AS V ON
				V.VarietyID = S.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID = V.CommodityID
 WHERE C.CommodityID	=	@CommodityID	AND
	   S.VarietyID		=	@VarietyID	AND 
	   StyleID			<	@StyleID
ORDER BY StyleID DESC


_GO_

ALTER PROCEDURE [dbo].[CommSizeAdd]
@SizeID			int,
@StyleID		int,
@SizeDesc		varchar(60),
@SizeEnDesc		varchar(60),
@CustomPrice	money,
@BoxNetWt		int,
@BoxTareWt		int,
@NoActive		bit,
@UpDatedByID	int,
@OrderKey		varchar(3),
@GTINDescription	varchar(20) = null,
@ItemNum	varchar(15),
@GTINCode VARCHAR(20) = NULL


AS

IF (SELECT COUNT(*) AS REGS FROM CommSize
	WHERE SizeID	= @SizeID) = 0
BEGIN
		INSERT INTO CommSize(StyleID, SizeDesc, SizeEnDesc, CustomPrice, BoxNetWt, BoxTareWt, NoActive,
							 LastUpDated, UpDatedByID, OrderKey, GTINDescription, ItemNum, GTINCode)
						VALUES(@StyleID, @SizeDesc, @SizeEnDesc, @CustomPrice, @BoxNetWt, @BoxTareWt, @NoActive,
							 GETDATE(), @UpDatedByID, @OrderKey, @GTINDescription, @ItemNum, @GTINCode)
								
		SET @SizeID = SCOPE_IDENTITY()
END
ELSE
BEGIN
	UPDATE CommSize SET				
		StyleID		=	@StyleID,
		SizeDesc	=	@SizeDesc,
		SizeEnDesc	=	@SizeEnDesc,
		CustomPrice	=	@CustomPrice,
		BoxNetWt	=	@BoxNetWt,
		BoxTareWt	=	@BoxTareWt,
		NoActive	=	@NoActive,
		LastUpDated	=	GETDATE(),
		UpDatedByID	=	@UpDatedByID,
		OrderKey	=	@OrderKey,
		GTINDescription	=	@GTINDescription,
		ItemNum		=	@ItemNum,
		GTINCode	=	@GTINCode
	WHERE SizeID = @SizeID
END

SELECT @SizeID AS SizeID


_GO_


ALTER PROCEDURE [dbo].[CommSizeFirst]
@CommodityID	INT,
@VarietyID		INT,
@StyleID		INT
AS
	
SELECT TOP 1 SI.SizeID, SI.SizeDesc, 
		SI.StyleID, SL.StyleDesc, 
		SL.VarietyID, V.VarDesc,
		V.CommodityID, C.CommDesc,
		SI.SizeEnDesc, SI.CustomPrice, SI.BoxNetWt, SI.BoxTareWt, SI.NoActive, SI.LastUpDated, 
		SI.UpDatedByID, SI.OrderKey, 
		CONVERT(VARCHAR, SI.OriginalVersion) as OriginalVersion,
		ISNULL(SI.GTINDescription, '') AS GTINDescription,
		ISNULL(SI.ItemNum, '') AS ItemNum,
		ISNULL(SI.GTINCode, '') AS GTINCode
		FROM CommSize AS SI
			INNER JOIN CommStyle AS SL ON
				SL.StyleID	=	SI.StyleID
			INNER JOIN CommVariety AS V ON
				SL.VarietyID = V.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID	=	V.CommodityID
 WHERE	C.CommodityID = @CommodityID	AND
		V.VarietyID	=	@VarietyID	AND
		SL.StyleID	=	@StyleID	
ORDER BY SizeID ASC

_GO_


ALTER PROCEDURE [dbo].[CommSizeGetByDescription]
@CommodityID	INT,
@VarietyID		INT,
@StyleID		INT,
@SizeDesc		VARCHAR(60)
AS

SELECT SI.SizeID, SI.SizeDesc, 
		SI.StyleID, SL.StyleDesc, 
		SL.VarietyID, V.VarDesc,
		V.CommodityID, C.CommDesc,
		SI.SizeEnDesc, SI.CustomPrice, SI.BoxNetWt, SI.BoxTareWt, SI.NoActive, SI.LastUpDated, 
		SI.UpDatedByID, SI.OrderKey, 
		CONVERT(VARCHAR, SI.OriginalVersion) as OriginalVersion,
		ISNULL(SI.GTINDescription, '') AS GTINDescription,
		ISNULL(SI.ItemNum, '') AS ItemNum,
		ISNULL(SI.GTINCode, '') AS GTINCode
		FROM CommSize AS SI
			INNER JOIN CommStyle AS SL ON
				SL.StyleID	=	SI.StyleID
			INNER JOIN CommVariety AS V ON
				SL.VarietyID = V.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID	=	V.CommodityID
WHERE	C.CommodityID	=	@CommodityID	AND
		V.VarietyID		=	@VarietyID	AND
		SL.StyleID		=	@StyleID	AND
		SI.SizeDesc		=	@SizeDesc

_GO_


ALTER PROCEDURE [dbo].[CommSizeGetByID]
@SizeID	INT
AS

SELECT SI.SizeID, SI.SizeDesc, 
		SI.StyleID, SL.StyleDesc, 
		SL.VarietyID, V.VarDesc,
		V.CommodityID, C.CommDesc,
		SI.SizeEnDesc, SI.CustomPrice, SI.BoxNetWt, SI.BoxTareWt, SI.NoActive, SI.LastUpDated, 
		SI.UpDatedByID, SI.OrderKey, 
		CONVERT(VARCHAR, SI.OriginalVersion) as OriginalVersion,
		ISNULL(SI.GTINDescription, '') AS GTINDescription,
		ISNULL(SI.ItemNum, '') AS ItemNum,
		ISNULL(SI.GTINCode, '') AS GTINCode
		FROM CommSize AS SI
			INNER JOIN CommStyle AS SL ON
				SL.StyleID	=	SI.StyleID
			INNER JOIN CommVariety AS V ON
				SL.VarietyID = V.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID	=	V.CommodityID
WHERE SizeID = @SizeID


_GO_

ALTER PROCEDURE [dbo].[CommSizeLast]
@CommodityID	INT,
@VarietyID		INT,
@StyleID		INT
AS
	
SELECT TOP 1 SI.SizeID, SI.SizeDesc, 
		SI.StyleID, SL.StyleDesc, 
		SL.VarietyID, V.VarDesc,
		V.CommodityID, C.CommDesc,
		SI.SizeEnDesc, SI.CustomPrice, SI.BoxNetWt, SI.BoxTareWt, SI.NoActive, SI.LastUpDated, 
		SI.UpDatedByID, SI.OrderKey, 
		CONVERT(VARCHAR, SI.OriginalVersion) as OriginalVersion,
		ISNULL(SI.GTINDescription, '') AS GTINDescription,
		ISNULL(SI.ItemNum, '') AS ItemNum,
		ISNULL(SI.GTINCode, '') AS GTINCode
		FROM CommSize AS SI
			INNER JOIN CommStyle AS SL ON
				SL.StyleID	=	SI.StyleID
			INNER JOIN CommVariety AS V ON
				SL.VarietyID = V.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID	=	V.CommodityID
 WHERE	C.CommodityID = @CommodityID	AND
		V.VarietyID	=	@VarietyID	AND
		SL.StyleID	=	@StyleID	
ORDER BY SizeID DESC
	
_GO_

ALTER PROCEDURE [dbo].[CommSizeNext]
@CommodityID	INT,
@VarietyID		INT,
@StyleID		INT,
@SizeID			INT
AS
	
SELECT TOP 1 SI.SizeID, SI.SizeDesc, 
		SI.StyleID, SL.StyleDesc, 
		SL.VarietyID, V.VarDesc,
		V.CommodityID, C.CommDesc,
		SI.SizeEnDesc, SI.CustomPrice, SI.BoxNetWt, SI.BoxTareWt, SI.NoActive, SI.LastUpDated, 
		SI.UpDatedByID, SI.OrderKey, CONVERT(VARCHAR, SI.OriginalVersion) as OriginalVersion,
		ISNULL(SI.GTINDescription, '') AS GTINDescription,
		ISNULL(SI.ItemNum, '') AS ItemNum,
		ISNULL(SI.GTINCode, '') AS GTINCode
		FROM CommSize AS SI
			INNER JOIN CommStyle AS SL ON
				SL.StyleID	=	SI.StyleID
			INNER JOIN CommVariety AS V ON
				SL.VarietyID = V.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID	=	V.CommodityID
 WHERE	C.CommodityID = @CommodityID	AND
		V.VarietyID	=	@VarietyID	AND
		SL.StyleID	=	@StyleID	AND
		SI.SizeID	>	@SizeID
ORDER BY SizeID ASC

_GO_

ALTER PROCEDURE [dbo].[CommSizePrevious]
@CommodityID	INT,
@VarietyID		INT,
@StyleID		INT,
@SizeID			INT
AS
	
SELECT TOP 1 SI.SizeID, SI.SizeDesc, 
		SI.StyleID, SL.StyleDesc, 
		SL.VarietyID, V.VarDesc,
		V.CommodityID, C.CommDesc,
		SI.SizeEnDesc, SI.CustomPrice, SI.BoxNetWt, SI.BoxTareWt, SI.NoActive, SI.LastUpDated, 
		SI.UpDatedByID, SI.OrderKey, CONVERT(VARCHAR, SI.OriginalVersion) as OriginalVersion,
		ISNULL(SI.GTINDescription, '') AS GTINDescription,
		ISNULL(SI.ItemNum, '') AS ItemNum,
		ISNULL(SI.GTINCode, '') AS GTINCode
		FROM CommSize AS SI
			INNER JOIN CommStyle AS SL ON
				SL.StyleID	=	SI.StyleID
			INNER JOIN CommVariety AS V ON
				SL.VarietyID = V.VarietyID
			INNER JOIN Commodity AS C ON
				C.CommodityID	=	V.CommodityID
 WHERE	C.CommodityID = @CommodityID	AND
		V.VarietyID	=	@VarietyID	AND
		SL.StyleID	=	@StyleID	AND
		SI.SizeID	<	@SizeID
ORDER BY SizeID DESC

_GO_


ALTER VIEW [dbo].[vwPalletaCommodityDesc]

AS

SELECT PT.PalletTagID,  C.*,
		CASE CF.Segment_1
			WHEN 0 THEN ISNULL(C.CommDesc, '''') --COMMODITY
			WHEN 1 THEN ISNULL(CV.VarDesc, '''') --VARIEDAD
			WHEN 2 THEN ISNULL(CS.StyleDesc, '''') --EMPAQUE
			WHEN 3 THEN ISNULL(CSS.SizeDesc, '''') --TAMANIO
			ELSE '' END
			+ ' ' + 
		CASE CF.Segment_2
			WHEN 0 THEN ISNULL(C.CommDesc, '') --COMMODITY
			WHEN 1 THEN ISNULL(CV.VarDesc, '') --VARIEDAD
			WHEN 2 THEN ISNULL(CS.StyleDesc, '') --EMPAQUE
			WHEN 3 THEN ISNULL(CSS.SizeDesc, '') --TAMANIO
			ELSE '' END
			+ ' ' + 
		CASE CF.Segment_3
			WHEN 0 THEN ISNULL(C.CommDesc, '') --COMMODITY
			WHEN 1 THEN ISNULL(CV.VarDesc, '') --VARIEDAD
			WHEN 2 THEN ISNULL(CS.StyleDesc, '') --EMPAQUE
			WHEN 3 THEN ISNULL(CSS.SizeDesc, '') --TAMANIO
			ELSE '' END
			+ ' ' +
		CASE CF.Segment_4
			WHEN 0 THEN ISNULL(C.CommDesc, '') --COMMODITY
			WHEN 1 THEN ISNULL(CV.VarDesc, '') --VARIEDAD
			WHEN 2 THEN ISNULL(CS.StyleDesc, '') --EMPAQUE
			WHEN 3 THEN ISNULL(CSS.SizeDesc, '') --TAMANIO
			ELSE '' END
		AS ProductDesc		
	FROM dbo.PalletTag AS PT
		INNER JOIN dbo.Commodity AS C ON
			C.CommodityID	=	PT.CommodityID
		INNER JOIN dbo.CommVariety AS CV ON
			CV.VarietyID	=	PT.VarietyID
		INNER JOIN dbo.CommFormat AS CF ON
			CF.FormatID		=	CV.FormatID
		INNER JOIN dbo.CommStyle AS CS ON
			CS.StyleID	=	PT.StyleID
		INNER JOIN dbo.CommSize AS CSS ON
			CSS.SizeID		=	PT.SizeID



_GO_

--rev505
ALTER TABLE Company ADD HasDestinations BIT NULL
_GO_
ALTER TABLE Distributors ADD DestinationID INT NULL
_GO_
ALTER TABLE PalletTag ADD DestinationID INT NULL
_GO_



ALTER PROCEDURE [dbo].[CompanyGet] 
 AS
 
 SELECT TOP 1 CompanyID, UserIDLastUpdate, CompanyName, Address1, Address2, City, StateID, ZipCode, CountryID,
		Phone, Phone2, Phone3, Fax, Mobile, Contact, WebSite, EMail, RFC, LastUpDated, 
		PreFix, TempMS, WeightMS, IsOneManifest, NoAssign, PalletTagStyleID, 
		CONVERT(VARCHAR, OriginalVersion) AS OriginalVersion, smltagwebsite, ISNULL(ShowGrowerInfo, 0) AS ShowGrowerInfo,
		ISNULL(SmallLabelType, 0) AS SmallLabelType,
		ISNULL(HasDestinations, 0) AS HasDestinations
 FROM Company
 

_GO_

ALTER PROCEDURE [dbo].[CompanyAdd]
@CompanyID			INT,
@UserIDLastUpdate	INT,
@CompanyName		VARCHAR(150),
@Address1			VARCHAR(80),
@Address2			VARCHAR(80),
@City				VARCHAR(80),
@StateID			VARCHAR(500),
@ZipCode			VARCHAR(100),
@CountryID			INT,
@Phone				VARCHAR(20),
@Phone2				VARCHAR(20),
@Phone3				VARCHAR(20),
@Fax				VARCHAR(20),
@Mobile				VARCHAR(20),
@Contact			VARCHAR(80),
@WebSite			VARCHAR(100),
@EMail				VARCHAR(100),
@RFC				VARCHAR(30),
@PreFix				VARCHAR(3),
@TempMS				VARCHAR(1),
@WeightMS			VARCHAR(1),
@IsOneManifest		BIT,
@NoAssign			BIT,
@PalletTagStyleID	VARCHAR(1),
@OriginalVersion	VARCHAR(100),
@smltagwebsite		VARCHAR(255),
@ShowGrowerInfo		BIT,
@SmallLabelType		BIT = NULL,
@HasDestinations BIT = NULL

 AS


DECLARE
@Result BIT
 
BEGIN TRANSACTION
 
 IF (SELECT COUNT(*) AS REGS FROM Company
	  WHERE CompanyID = @CompanyID) = 0
	BEGIN
		SET @Result = 1
		--INSERT
		INSERT INTO Company(UserIDLastUpdate, CompanyName, Address1, Address2, City, StateID, ZipCode, CountryID,
							Phone, Phone2, Phone3, Fax, Mobile, Contact, WebSite, EMail, RFC, LastUpDated,
							PreFix, TempMS, WeightMS, IsOneManifest, NoAssign, PalletTagStyleID, smltagwebsite, ShowGrowerInfo, SmallLabelType,
							HasDestinations)
				VALUES(@UserIDLastUpdate, @CompanyName, @Address1, @Address2, @City, @StateID, @ZipCode, @CountryID,
							@Phone, @Phone2, @Phone3, @Fax, @Mobile, @Contact, @WebSite, @EMail, @RFC, GETDATE(),
							@PreFix, @TempMS, @WeightMS, @IsOneManifest, @NoAssign, @PalletTagStyleID, @smltagwebsite,
							@ShowGrowerInfo, @SmallLabelType, @HasDestinations)
	END
	ELSE
	BEGIN
	
	IF NOT (SELECT COUNT(*) AS REGS FROM Company
		WHERE  CompanyID = @CompanyID --AND
	       --OriginalVersion = CONVERT(TimeStamp, @OriginalVersion)
	       ) = 0
	BEGIN   
	   
		--UPDATE
		UPDATE Company SET
			UserIDLastUpdate	=	@UserIDLastUpdate,
			CompanyName			=	@CompanyName, 
			Address1			=	@Address1, 
			Address2			=	@Address2, 
			City				=	@City, 
			StateID				=	@StateID, 
			ZipCode				=	@ZipCode, 
			CountryID			=	@CountryID,
			Phone				=	@Phone, 
			Phone2				=	@Phone2, 
			Phone3				=	@Phone3, 
			Fax					=	@Fax, 
			Mobile				=	@Mobile, 
			Contact				=	@Contact, 
			WebSite				=	@WebSite, 
			EMail				=	@EMail, 
			RFC					=	@RFC, 
			LastUpDated			=	GETDATE(),
			PreFix				=	@PreFix, 
			TempMS				=	@TempMS, 
			WeightMS			=	@WeightMS, 
			IsOneManifest		=	@IsOneManifest, 
			NoAssign			=	@NoAssign, 
			PalletTagStyleID	=	@PalletTagStyleID,
			smltagwebsite		=	@smltagwebsite,
			ShowGrowerInfo		=	@ShowGrowerInfo,
			SmallLabelType		=	@SmallLabelType,
			HasDestinations	=	@HasDestinations
		WHERE CompanyID = @CompanyID
		SET @Result = 1
	END
	ELSE
	BEGIN
	
		SET @Result = 0
		
		
	   
	END
END
 
 SELECT @Result AS Result
 
 SELECT U.*, C.LastUpDated AS LastUpdateUser
		FROM Company AS C 
			INNER JOIN Users AS U ON
				U.UserID	=	C.UserIDLastUpdate
			WHERE  CompanyID = @CompanyID 
				   

IF (SELECT @@error) = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION
	
	
_GO_


ALTER PROCEDURE [dbo].[DistributorsGetByID]
@DistributorID	INT
AS
	
SELECT DistributorID, Owner, Contact, OfficeManager, OffPhone, OffFax, OffMngEMail, FloorMan, WhsePhone,
		WhseFax, WhseEMail, TransitTime, QualityControlBy, QCPhone, QCEMail, NotActive, LastUpDated,
		UpDatedByID, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINCode, '') AS GTINCode, ISNULL(Location, '') AS Location,
		ISNULL(DestinationID, 0) AS DestinationID
 FROM Distributors
WHERE DistributorID = @DistributorID

_GO_




ALTER PROCEDURE [dbo].[PackerGetTablesRequired]

AS

SELECT * FROM Packer ORDER BY PackerName
SELECT * FROM Grower WHERE NoActive = 0 ORDER BY GrowerShDesc
SELECT * FROM Fields WHERE NoActive = 0 ORDER BY FldDesc
SELECT * FROM Lots WHERE NoActive = 0 ORDER BY LotDesc
SELECT * FROM Segments WHERE NoActive = 0 ORDER BY SegDesc

SELECT C.*, COM.CommDesc, V.VarDesc
FROM Crops AS C
	INNER JOIN Commodity AS COM ON
		COM.CommodityID = C.CommodityID
	INNER JOIN CommVariety AS V ON
		V.VarietyID = C.VarietyID
WHERE C.NoActive = 0 	  
ORDER BY CropDesc

SELECT * FROM CommStyle WHERE NoActive = 0 ORDER BY StyleDesc
SELECT * FROM CommSize WHERE NoActive = 0 ORDER BY SizeDesc
SELECT * FROM Labels WHERE NoActive = 0 ORDER BY LabelDesc
SELECT * FROM Commodity WHERE NoActive = 0 ORDER BY CommDesc
SELECT * FROM PackerGrower

--11
SELECT * FROM Distributors
WHERE NOT ISNULL(DestinationID, 0) = 0

_GO_


ALTER PROCEDURE [dbo].[PalletTagUpdate]
@PalletTagID	int, 
@PackerID		INT,
@GrowerID		INT,
@CommodityID	INT,	
@VarietyID		INT,
@StyleID		int,
@SizeID			int,
@LabelID		int,
@FieldID		int,
@SegmentID		int,
@LotID			int,
@CropID			int,
@IsChep			bit,
@HarvestDate	varchar(50),
@PackedDate		varchar(50),
@Pkgs			int,
@UpDatedByID	int,
@DestinationID INT

AS

BEGIN TRANSACTION

UPDATE PalletTag SET
	PackerID	=	@PackerID,
	GrowerID	=	@GrowerID,
	CommodityID	=	@CommodityID,
	VarietyID	=	@VarietyID,
	StyleID		=	@StyleID, 
	SizeID		=	@SizeID, 
	LabelID		=	@LabelID, 
	FieldID		=	@FieldID, 
	SegmentID	=	@SegmentID,
	LotID		=	@LotID, 
	CropID		=	@CropID, 
	IsChep		=	@IsChep, 
	HarvestDate	=	@HarvestDate, 
	PackedDate	=	@PackedDate, 	
	Pkgs		=	@Pkgs, 		
	UpDatedByID	=	@UpDatedByID,
	DestinationID	= CASE WHEN	ISNULL(@DestinationID, 0) = 0 THEN NULL ELSE @DestinationID END
WHERE PalletTagID = @PalletTagID
		
	
	
	
IF (SELECT @@error) = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION
	
_GO_


ALTER PROCEDURE [dbo].[PalletTag_Create]
		@SeasonID		int,		
		@PackerID		int,
		@GrowerID		int,
		@PreFix 		varChar(3),
		@CommodityID		int,
		@VarietyID		int,
		@StyleID		int,
		@SizeID			int,
		@LabelID		int,
		@FieldID		int,
		@SegmentID		int,
		@LotID			int,
		@CropID			int,
		@IsChep			bit = 0,
		@HarvestDate		smalldatetime,
		@PackedDate		smalldatetime,
		@PakedByID		varchar(5)=null,
		@Pkgs			int,
		@PalletsQty		int,
		@UserID			int,
		@OverWeight		varchar(1),
		@DestinationID INT
AS

BEGIN TRAN -- start transaction
	
	DECLARE @LockTag int , @PalletNum int, @PalletCounter int, @date datetime, @ReturnValue INT
		
	/*Lock PalletTag Table*/
  	SET  @LockTag = (SELECT top 1  PalletTagID FROM  PalletTag (TABLOCKX))
	

	
	--SELECT CONVERT(INT,(RAND( (DATEPART(mm, GETDATE()) * 100000) +
 --                  (DATEPART(ss, GETDATE()) * 1000      ) +
 --             	   (DATEPART(ms, GETDATE()) ) ) * 1000000))

	SET @PalletNum = Null  -- initialize next pallet number to null value
	SET @PalletCounter = 0
	set @date = GETDATE()

	WHILE 1=1 /*Loop PalletsQty*/
		BEGIN
			IF @PalletCounter = @PalletsQty
				BEGIN
						COMMIT TRAN
						SET @ReturnValue = 0
        				BREAK
				END

			/* get the next random pallet number */
			WHILE (1 = 1)
				BEGIN
					SET @PalletNum = (SELECT convert(int,rand()*1000000))
					IF @@error <> 0
   					BEGIN
   						ROLLBACK TRAN					   						
   						SET @ReturnValue = 1
   						BREAK
	   	           		--RETURN 1
   		           	END
					IF @PalletNum < 1000000 AND @PalletNum > 0
         			BEGIN
            				IF Not EXISTS (SELECT PalletTagID FROM PalletTag
					       WHERE SeasonID = @SeasonID
					       AND PalletTagNum =  @PalletNum)              				
					BREAK
				END           
   			END /*End Get PalletTag Num*/

         				
			INSERT INTO PalletTag (SeasonID,PackerID,GrowerID,CommodityID,VarietyID,StyleID,SizeID,LabelID,
			      	               FieldID,SegmentID,LotID,CropID,IsChep,HarvestDate,PackedDate,PakedByID,Pkgs,
					       PkgsShp,Status,CreatedDate,UpDatedByID,PreFix,PalletTagNum,CreatedByID, OverWeight,
								 DestinationID)
			Values(@SeasonID,@PackerID,@GrowerID,@CommodityID,@VarietyID,@StyleID,@SizeID,@LabelID,
			       @FieldID,@SegmentID,@LotID,@CropID,@IsChep,@HarvestDate,@PackedDate,
			       @PakedByID,@Pkgs,0,1,@date,@UserID,@PreFix,@PalletNum,@UserID, @OverWeight,
						 CASE WHEN ISNULL(@DestinationID, 0) = 0 THEN NULL ELSE @DestinationID END)
			       
			       
			
			IF (SELECT @@error) <> 0
				BEGIN
					ROLLBACK TRAN									
   	      			--RETURN 1
   	      			SET @ReturnValue = 1
   	      			BREAK
				END
			SET @PalletCounter = @PalletCounter + 1
		END /*End Create total PalletsQty*/


	SELECT @date AS CreateDate, @PalletCounter AS PalletCreated, @ReturnValue AS ReturnValue

_GO_



ALTER PROCEDURE [dbo].[PalletTagGetByID]
@PalletTagID	INT

AS

SELECT PT.PalletTagID, PT.SeasonID, 
		PT.PackerID, PackerName,
		PT.GrowerID, GrowerShDesc,
		PT.CommodityID, CommDesc,
		PT.VarietyID, VarDesc,
		PT.StyleID, StyleDesc,
		PT.SizeID, SizeDesc,
		PT.LabelID, LabelDesc,
		PT.FieldID, FldDesc,
		PT.SegmentID, SegDesc,
		PT.LotID, LotDesc,
		PT.CropID, CropDesc,
		PT.IsChep,
		PT.HarvestDate,
		PT.PackedDate,
		PT.PakedByID,
		PT.Pkgs, PT.PkgsShp, PT.Status, PT.CreatedDate, PT.UpDatedByID, PT.PreFix,
		dbo.PalletTag_ZeroFill(PT.PalletTagNum) AS PalletTagNum, PT.CreatedByID, PT.OverWeight,
		CustomPrice, 
		ISNULL(PT.DestinationID, 0) AS DestinationID
	FROM PalletTag AS PT
		INNER JOIN Packer AS P ON
			P.PackerID = PT.PackerID
		INNER JOIN Grower AS G ON
			G.GrowerID = PT.GrowerID
		INNER JOIN Commodity AS C ON
			C.CommodityID = PT.CommodityID
		LEFT JOIN CommVariety AS CV ON
			CV.CommodityID = PT.CommodityID AND
			CV.VarietyID	=	PT.VarietyID
		INNER JOIN CommStyle AS S ON
			S.StyleID = PT.StyleID			
		INNER JOIN CommSize AS SI ON
			SI.SizeID = PT.SizeID
		INNER JOIN Labels AS L ON
			L.LabelID = PT.LabelID
		INNER JOIN Fields AS F ON
			F.FieldID	= PT.FieldID
		INNER JOIN Segments AS SEG ON
			SEG.SegmentID = PT.SegmentID
		INNER JOIN Lots AS LOT ON
			LOT.LotID	= PT.LotID
		INNER JOIN Crops AS CR ON
			CR.CropID = PT.CropID
WHERE PT.PalletTagID	= @PalletTagID

_GO_

--REV506
ALTER TABLE Distributors ADD ShortName VARCHAR(15) NULL

_GO_

CREATE TABLE [dbo].[DistributorSeasons](
	[DistSeasonID] [int] IDENTITY(1,1) NOT NULL,
	[DistributorID] [int] NOT NULL,
	[Description] [nvarchar](40) NOT NULL,
	[FromDate] [datetime] NOT NULL,
	[ToDate] [datetime] NOT NULL,
	[OrderKey]	varchar(3) null,
	[LastUpDated] [datetime] NOT NULL,
	[UpdateByUserID] [int] NOT NULL,
	[OriginalVersion] [timestamp] NULL,
	[Default_Season] [bit] NOT NULL,
	[QRCodePreFix] [varchar](20) NULL,
 CONSTRAINT [PK_DistributorSeasons] PRIMARY KEY CLUSTERED 
(
	[DistSeasonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

_GO_


ALTER PROCEDURE [dbo].[DistributorsAdd]
@DistributorID		int,
@Owner				varchar(80),
@Contact			varchar(80),
@OfficeManager		varchar(80),
@OffPhone			varchar(20),
@OffFax				varchar(20),
@OffMngEMail		varchar(100),
@FloorMan			varchar(80),
@WhsePhone			varchar(20),
@WhseFax			varchar(20),
@WhseEMail			varchar(100),
@TransitTime		int,
@QualityControlBy	varchar(80),
@QCPhone			varchar(20),
@QCEMail			varchar(50),
@NotActive			bit,
@UpDatedByID		int,
@OriginalVersion	VARCHAR(100),
@GTINCode			VARCHAR(20) = NULL,
@Location			VARCHAR(15) = NULL,
@DestinationID INT = NULL,
@ShortName VARCHAR(15) = NULL


AS

DECLARE
@Result BIT

BEGIN TRANSACTION

--Si es nuevo registro, pero el nombre ya lo registro otro usuario
IF @DistributorID = -1 OR @DistributorID = 0
BEGIN
	SET @DistributorID = ISNULL((SELECT DistributorID FROM Distributors WHERE Owner = @Owner), @DistributorID)
END

IF (SELECT COUNT(*) AS REGS FROM Distributors
	WHERE DistributorID = @DistributorID) = 0
	BEGIN
		SET @Result = 1
	
		INSERT INTO Distributors(Owner, Contact, OfficeManager, OffPhone, OffFax, OffMngEMail, FloorMan,
						WhsePhone, WhseFax, WhseEMail, TransitTime, QualityControlBy, QCPhone, QCEMail,
						NotActive, LastUpDated, UpDatedByID, GTINCode, Location, DestinationID, ShortName)
					VALUES(@Owner, @Contact, @OfficeManager, @OffPhone, @OffFax, @OffMngEMail, @FloorMan,
						@WhsePhone, @WhseFax, @WhseEMail, @TransitTime, @QualityControlBy, @QCPhone, @QCEMail,
						@NotActive, GETDATE(), @UpDatedByID, 
						@GTINCode, @Location, @DestinationID, @ShortName)
							  
		SET @DistributorID = SCOPE_IDENTITY()
	END
	
	ELSE
	BEGIN
	
		IF NOT (SELECT COUNT(*) AS REGS FROM Distributors
		WHERE  DistributorID = @DistributorID AND
			OriginalVersion = CONVERT(TimeStamp, @OriginalVersion)) = 0
		BEGIN   
		
			UPDATE Distributors SET
				Owner	=	@Owner, 
				Contact	=	@Contact, 
				OfficeManager	=	@OfficeManager, 
				OffPhone	=	@OffPhone, 
				OffFax		=	@OffFax, 
				OffMngEMail	=	@OffMngEMail, 
				FloorMan	=	@FloorMan,
				WhsePhone	=	@WhsePhone, 
				WhseFax		=	@WhseFax, 
				WhseEMail	=	@WhseEMail, 
				TransitTime	=	@TransitTime, 
				QualityControlBy	=	@QualityControlBy, 
				QCPhone		=	@QCPhone, 
				QCEMail		=	@QCEMail,
				NotActive	=	@NotActive, 
				LastUpDated	=	GETDATE(), 
				UpDatedByID	=	UpDatedByID,
				GTINCode	=	@GTINCode,
				Location	=	@Location,
				DestinationID	=	@DestinationID,
				ShortName	=	@ShortName
			WHERE DistributorID = @DistributorID
	
			SET @Result = 1
		END
		ELSE
		BEGIN	
				SET @Result = 0
		END
	END
	
	
	SELECT DistributorID, CONVERT(VARCHAR, OriginalVersion) AS OriginalVersion FROM Distributors
	WHERE DistributorID = @DistributorID
	
	SELECT @Result AS Result
	
	SELECT U.*, C.LastUpDated AS LastUpdateUser
		FROM Distributors AS C 
			INNER JOIN Users AS U ON
				U.UserID	=	C.UpDatedByID
			WHERE  DistributorID = @DistributorID
			
			
IF (SELECT @@error) = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION


_GO_

ALTER PROCEDURE [dbo].[DistributorsGetByDesc]
@Owner	VARCHAR(80)
AS
	
SELECT DistributorID, Owner, Contact, OfficeManager, OffPhone, OffFax, OffMngEMail, FloorMan, WhsePhone,
		WhseFax, WhseEMail, TransitTime, QualityControlBy, QCPhone, QCEMail, NotActive, LastUpDated,
		UpDatedByID, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINCode, '') AS GTINCode, ISNULL(Location, '') AS Location,
		ISNULL(ShortName, '') AS ShortName
 FROM Distributors
WHERE Owner = @Owner

_GO_

ALTER PROCEDURE [dbo].[DistributorsGetByID]
@DistributorID	INT
AS
	
SELECT DistributorID, Owner, Contact, OfficeManager, OffPhone, OffFax, OffMngEMail, FloorMan, WhsePhone,
		WhseFax, WhseEMail, TransitTime, QualityControlBy, QCPhone, QCEMail, NotActive, LastUpDated,
		UpDatedByID, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion,
		ISNULL(GTINCode, '') AS GTINCode, ISNULL(Location, '') AS Location,
		ISNULL(DestinationID, 0) AS DestinationID,
		ISNULL(ShortName, '') AS ShortName
 FROM Distributors
WHERE DistributorID = @DistributorID

_GO_


CREATE PROCEDURE [dbo].[DistributorSeasonsAdd]
@SeasonID		int,
@DistributorID int,
@Description	varchar(80),
@FromDate		varchar(50),
@ToDate			varchar(50),
@OrderKey		varchar(3),
@UpdateByUserID	int,
@Default_Season	bit,
@OriginalVersion	varchar(100),
@QRCodePreFix	VARCHAR(20)

AS

DECLARE
@Result BIT

BEGIN TRANSACTION

--Si es nuevo registro, pero el nombre ya lo registro otro usuario
IF @SeasonID = -1 OR @SeasonID = 0
BEGIN
	SET @SeasonID = ISNULL((SELECT DistSeasonID
													FROM DistributorSeasons
													WHERE DistributorID = @DistributorID AND Description = @Description), @SeasonID)
END

IF (SELECT COUNT(*) AS REGS FROM DistributorSeasons
	WHERE DistSeasonID = @SeasonID) = 0
	BEGIN
		
		SET @Result = 1
	
		INSERT INTO DistributorSeasons(DistributorID, Description, FromDate, ToDate, OrderKey, LastUpDated, UpdateByUserID, Default_Season,
							QRCodePreFix)
					VALUES(@DistributorID, @Description, @FromDate, @ToDate, @OrderKey, GETDATE(), @UpdateByUserID, @Default_Season,
							@QRCodePreFix)
							  
		SET @SeasonID = SCOPE_IDENTITY()
	END
	
	ELSE
	BEGIN
	
		IF NOT (SELECT COUNT(*) AS REGS FROM DistributorSeasons
			WHERE  DistSeasonID = @SeasonID AND
					OriginalVersion = CONVERT(TimeStamp, @OriginalVersion)) = 0
		BEGIN   
		
			UPDATE DistributorSeasons SET
				Description	=	@Description,
				FromDate	=	@FromDate,
				ToDate		=	@ToDate,
				OrderKey	=	@OrderKey,
				LastUpDated	=	GETDATE(),
				UpdateByUserID	=	@UpdateByUserID,
				Default_Season	=	@Default_Season,
				QRCodePreFix	=	@QRCodePreFix
			WHERE DistSeasonID = @SeasonID
		
			SET @Result = 1
		END
		ELSE
		BEGIN	
			SET @Result = 0
		END
	
	END
	
	--Si esta es la temporada default, desactivo las demas.
		IF @Default_Season = 1
		BEGIN
		UPDATE DistributorSeasons SET
			Default_Season = 0
		WHERE NOT DistSeasonID = @SeasonID AND
				DistributorID	=	@DistributorID
		END
		
		
	SELECT DistSeasonID AS SeasonID, CONVERT(VARCHAR, OriginalVersion) AS OriginalVersion FROM DistributorSeasons
	WHERE DistSeasonID = @SeasonID
	
	SELECT @Result AS Result
 
	SELECT U.*, P.LastUpDated AS LastUpdateUser
		FROM DistributorSeasons AS P
			INNER JOIN Users AS U ON
				U.UserID	=	P.UpdateByUserID
			WHERE  DistSeasonID = @SeasonID
	
	
IF (SELECT @@error) = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION
	
_GO_

CREATE PROCEDURE [dbo].[DistributorSeasonsGetAll]
@DistributorID int,
@SeasonID	INT,
@Description		VARCHAR(80)
AS
	
SELECT DistSeasonID AS SeasonID, DistributorID, Description, FromDate, ToDate, OrderKey, LastUpDated, UpdateByUserID, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion, Default_Season,
	   ISNULL(QRCodePreFix, '') AS QRCodePreFix
 FROM DistributorSeasons
 WHERE DistributorID	=	@DistributorID AND
		 DistSeasonID = CASE WHEN @SeasonID = -1 THEN DistSeasonID ELSE @SeasonID END AND
	   Description LIKE @Description
ORDER BY Description

_GO_




CREATE PROCEDURE [dbo].[DistributorSeasonsGetByID]
@DistributorID int,
@SeasonID	INT
AS
	
SELECT DistSeasonID AS SeasonID, DistributorID, Description, FromDate, ToDate, OrderKey, LastUpDated, UpdateByUserID, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion, Default_Season,
	   ISNULL(QRCodePreFix, '') AS QRCodePreFix
 FROM DistributorSeasons
  WHERE DistributorID	=	@DistributorID AND
		DistSeasonID = @SeasonID

_GO_


CREATE PROCEDURE [dbo].[DistributorSeasonsDelete]
 @SeasonID	INT
 AS
 
 DELETE FROM DistributorSeasons
 WHERE DistSeasonID = @SeasonID
 

_GO_


CREATE PROCEDURE [dbo].[DistributorSeasonsGetByDesc]
@DistributorID int,
@Description	VARCHAR(80)
AS
	
SELECT DistSeasonID AS SeasonID, DistributorID, Description, FromDate, ToDate, OrderKey, LastUpDated, UpdateByUserID, CONVERT(VARCHAR, OriginalVersion) as OriginalVersion, Default_Season,
	   ISNULL(QRCodePreFix, '') AS QRCodePreFix
 FROM DistributorSeasons	
WHERE DistributorID	=	@DistributorID AND
			Description = @Description

_GO_

ALTER TABLE [dbo].[PalletTag]  DROP CONSTRAINT [FK_PalletTag_Seasons] 

_GO_

ALTER PROCEDURE [dbo].[PalletTag_Create]
		@SeasonID		int,		
		@PackerID		int,
		@GrowerID		int,
		@PreFix 		varChar(3),
		@CommodityID		int,
		@VarietyID		int,
		@StyleID		int,
		@SizeID			int,
		@LabelID		int,
		@FieldID		int,
		@SegmentID		int,
		@LotID			int,
		@CropID			int,
		@IsChep			bit = 0,
		@HarvestDate		smalldatetime,
		@PackedDate		smalldatetime,
		@PakedByID		varchar(5)=null,
		@Pkgs			int,
		@PalletsQty		int,
		@UserID			int,
		@OverWeight		varchar(1),
		@DestinationID INT
AS

BEGIN TRAN -- start transaction
	
	DECLARE @LockTag int , @PalletNum int, @PalletCounter int, @date datetime, @ReturnValue INT
		
	/*Lock PalletTag Table*/
  	SET  @LockTag = (SELECT top 1  PalletTagID FROM  PalletTag (TABLOCKX))
	

	--Checa si tiene activo la opcion de controlar destinations
	IF (SELECT COUNT(*) AS Records
				FROM Company
			WHERE HasDestinations = 1) > 0
	BEGIN
	
		SET @SeasonID = ISNULL((SELECT TOP 1 DistSeasonID
											FROM Distributors AS D
												INNER JOIN DistributorSeasons AS S ON
													S.DistributorID	=	D.DistributorID
											WHERE DestinationID	=	 @DestinationID AND
													S.Default_Season = 1), @SeasonID)

	END



	
	--SELECT CONVERT(INT,(RAND( (DATEPART(mm, GETDATE()) * 100000) +
 --                  (DATEPART(ss, GETDATE()) * 1000      ) +
 --             	   (DATEPART(ms, GETDATE()) ) ) * 1000000))

	SET @PalletNum = Null  -- initialize next pallet number to null value
	SET @PalletCounter = 0
	set @date = GETDATE()

	WHILE 1=1 /*Loop PalletsQty*/
		BEGIN
			IF @PalletCounter = @PalletsQty
				BEGIN
						COMMIT TRAN
						SET @ReturnValue = 0
        				BREAK
				END

			/* get the next random pallet number */
			WHILE (1 = 1)
				BEGIN
					SET @PalletNum = (SELECT convert(int,rand()*1000000))
					IF @@error <> 0
   					BEGIN
   						ROLLBACK TRAN					   						
   						SET @ReturnValue = 1
   						BREAK
	   	           		--RETURN 1
   		           	END
					IF @PalletNum < 1000000 AND @PalletNum > 0
         			BEGIN
            				IF Not EXISTS (SELECT PalletTagID FROM PalletTag
					       WHERE SeasonID = @SeasonID
					       AND PalletTagNum =  @PalletNum)              				
					BREAK
				END           
   			END /*End Get PalletTag Num*/

         				
			INSERT INTO PalletTag (SeasonID,PackerID,GrowerID,CommodityID,VarietyID,StyleID,SizeID,LabelID,
			      	               FieldID,SegmentID,LotID,CropID,IsChep,HarvestDate,PackedDate,PakedByID,Pkgs,
					       PkgsShp,Status,CreatedDate,UpDatedByID,PreFix,PalletTagNum,CreatedByID, OverWeight,
								 DestinationID)
			Values(@SeasonID,@PackerID,@GrowerID,@CommodityID,@VarietyID,@StyleID,@SizeID,@LabelID,
			       @FieldID,@SegmentID,@LotID,@CropID,@IsChep,@HarvestDate,@PackedDate,
			       @PakedByID,@Pkgs,0,1,@date,@UserID,@PreFix,@PalletNum,@UserID, @OverWeight,
						 CASE WHEN ISNULL(@DestinationID, 0) = 0 THEN NULL ELSE @DestinationID END)
			       
			       
			
			IF (SELECT @@error) <> 0
				BEGIN
					ROLLBACK TRAN									
   	      			--RETURN 1
   	      			SET @ReturnValue = 1
   	      			BREAK
				END
			SET @PalletCounter = @PalletCounter + 1
		END /*End Create total PalletsQty*/


	SELECT @date AS CreateDate, @PalletCounter AS PalletCreated, @ReturnValue AS ReturnValue

_GO_


ALTER PROCEDURE [dbo].[ManifHGGetByStatus]
@DistributorID INT,
@Status		INT

AS

--EN LA COMPANIA MEDIDA DE PESO
DECLARE
@WIGHTUNIDAD VARCHAR(10)
SET @WIGHTUNIDAD = (SELECT TOP 1 WeightMS FROM Company)


SELECT H.ManifestID, H.SeasonID, H.ShpDate, H.Seq, H.Status, H.PackerID, H.GrowerID, H.GroReference,
		H.InvoiceNum, H.DistriburorID, H.MxCustoBkID, H.UsCustoBkID, H.Driver, H.MaintainTemHi, H.MaintainTemLo,
		H.TransporterID, H.Trailer, H.TruckLic, H.TrailerLic, H.DriverLic, H.SecSeal, H.Freight,
		H.FreightPdByDist, H.PayToName, H.Currency, H.CancelDate, H.Notes, H.UpDatedByID, H.LastUpDate,
		H.OriginalVersion, H.LdTemp, H.LocationID,
		ISNULL(H.SCACCode, '') AS SCACCode,
		CBUSA.Attention AS UsCustBkDesc, CBMX.Attention AS MxCustBkDesc,
		@WIGHTUNIDAD AS MedidaUsada, 
		P.ExternalCode AS ExternalCodePacker,
		PG.ExternalCode AS ExternalCodeGrower,
		ISNULL(Dist.ShortName, 'Default') AS DistributorShName
	FROM ManifHD AS H
	INNER JOIN Packer AS P ON
			P.PackerID	=	H.PackerID	
	INNER JOIN PackerGrower AS PG ON
			PG.PackerID	=	H.PackerID AND
			PG.GrowerID	=	H.GrowerID
	LEFT JOIN Distributors AS Dist ON
		Dist.DistributorID	=	H.DistriburorID				
	LEFT JOIN CustomBrokers AS CBUSA ON
		CBUSA.CustomBkID	=	H.UsCustoBkID	
	LEFT JOIN CustomBrokers AS CBMX ON
		CBMX.CustomBkID	=	H.MxCustoBkID
	LEFT JOIN Trasporters AS TR ON
		TR.TransporterID	=	H.TransporterID
WHERE Status = @Status AND
			H.DistriburorID = @DistributorID


SELECT D.*, PT.PreFix, PT.PalletTagNum, --PT.CommodityID, 
		dbo.MkProdCode (PT.CommodityID, PT.VarietyID, PT.StyleID, PT.SizeID ) AS CommodityID,
		C.CommDesc, 		
	    PT.LabelID, L.LabelDesc, D.PkgsEmb AS Pkgs,
		EMPAQUE.BoxNetWt * EMPAQUE.PalletQty AS PesoPaleta, @WIGHTUNIDAD AS MedidaUsadaEnPalleta, 
		'' AS CodigoColor, '' AS PrecioExportacion, 
		PT.OverWeight AS SobrePesada, C.MaturityDays AS GradoDeMaduracion, 
		PT.IsChep, F.FldDesc AS CampoDeSiembra,
		LOT.LotDesc AS LoteDeSiembra, SEG.SegDesc AS Segmento, CROP.CropDesc AS Cultivo,
		PT.HarvestDate AS FechaDeCorte, PT.PackedDate AS FechaDeEmpaque,
		PCD.ProductDesc, ISNULL(PT.VoicePick1, '') + ISNULL(PT.VoicePick2, '') AS VoiceCode,
		ISNULL(H.SCACCode, '') AS SCACCode,
		ISNULL(DestinationID, 0) AS DestinationID
	FROM ManifHD AS H		
		INNER JOIN ManifPT AS D ON
			D.ManifestID	=	H.ManifestID
		LEFT JOIN PalletTag AS PT ON
			PT.PalletTagID	=	D.PalletTagID
		INNER JOIN vwPalletaCommodityDesc AS PCD ON	
			PCD.PalletTagID	=	PT.PalletTagID
		LEFT JOIN Commodity AS C ON
			C.CommodityID	=	PT.CommodityID
		LEFT JOIN Labels AS L ON
			L.LabelID	=	PT.LabelID
		LEFT JOIN Fields AS F ON
			F.FieldID	=	PT.FieldID
		LEFT JOIN Lots AS LOT ON
			LOT.LotID	=	PT.LotID
		LEFT JOIN Segments AS SEG ON
			SEG.SegmentID	=	PT.SegmentID
		LEFT JOIN Crops AS CROP ON
			CROP.CropID		=	PT.CropID
		LEFT JOIN CommStyle AS EMPAQUE ON
			EMPAQUE.StyleID	=	PT.StyleID
WHERE H.Status	=	@Status AND
		  H.DistriburorID = @DistributorID

SELECT TOP 1 ISNULL(HasDestinations, 0) AS HasDestinations FROM Company

_GO_

ALTER PROCEDURE [dbo].[GetPalletsToPrint]
@CreatedDate VARCHAR(50), 
@PalletTagID INT

AS
 

DECLARE @CountryDesc AS VARCHAR(3)
DECLARE @CoWebSite AS VARCHAR(100)
DECLARE @ShowGrowerInfo AS BIT 
DECLARE @Siguiente	 datetime

set @Siguiente = @CreatedDate
set @Siguiente = DATEADD(ss, 1, @Siguiente)

SELECT @CoWebSite = ISNULL(Cm.WebSite,''), 
	   @ShowGrowerInfo = Cm. ShowGrowerInfo,
	   @CountryDesc = Cy.CountryAlias
FROM dbo.Company Cm INNER JOIN
	 Countries Cy ON Cm.CountryID = Cy.CountryID

 

SELECT Pt.PalletTagID,
	 	CONVERT(VARCHAR, Pt.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(Pt.PalletTagNum)) AS PalletTagNumwithPrefix,
		Co.CommEnDesc As Commodity, 
		Va.varEnDesc AS Variety,
		St.StyleEnDesc As Style,
		Sz.SizeEnDesc As SIZE,
		Lb.LabelShDesc As Label,
		UPPER(Left(REPLACE(Co.CommShDesc,' ',''),3)) As ShComm,
		UPPER(Left(REPLACE(Va.VarShDesc,' ',''),3)) As ShVar,
		UPPER(Left(REPLACE(St.StyleShDesc, ' ',''),3)) As ShSty,
		UPPER(Left(REPLACE(Sz.SizeDesc, ' ',''),3)) As ShSz,
		Pt.PreFix, dbo.PalletTag_ZeroFill(Pt.PalletTagNum) As PalletTagNum,
	    (Pt.Pkgs) AS Pkgs,
	    --(Pt.Pkgs-PkgsShp) AS Pkgs,
	    @CountryDesc AS SourceCountry,
		ISNULL(St.BoxQty,0) As UnitsByBox, 
		CASE WHEN @ShowGrowerInfo = 1 THEN Pk.PackerName ELSE Pk.PackerName END As PackerDesc,		
		NULL AS ShExternalRef, 
		NULL AS ExternalRef, 
		NULL AS ReferenceToPrint, 
		CASE WHEN Pk.WebSite IS NULL OR Pk.WebSite = ''
			THEN @CoWebSite 
			ELSE ISNULL(Pk.WebSite,'')
		END As SmlTagWebSite,
		GrowerShDesc, F.FldDesc, L.LotDesc, S.SegDesc, CR.CropDesc, Pt.IsChep, HarvestDate, PackedDate,
		CASE Pt.Status
			WHEN 0 THEN 'Borrada'
			WHEN 1 THEN 'Creada'
			WHEN 2 THEN 'Impresa'
			WHEN 3 THEN 'Asignada'
			WHEN 4 THEN 'Terminada'
			ELSE 'None' END AS StatusPallets, PkgsShp,
			Co.CommDesc, Va.VarDesc, St.StyleDesc, Sz.SizeDesc, Lb.LabelDesc,
			--Campos para el formato alternativo
			--(01)+GTIN DIst. Code (10)+PreFix+PalletNum+?00?





--select 			
			dbo.fGTINCode(Sz.GTINCode, St.GTINCode, Va.GTINCode, 
									  Co.GTINCode, DIST.GTINCode) AS GTINCode,
			--DIST.GTINCode,

			CONVERT(VARCHAR, Pt.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(Pt.PalletTagNum)) + '00' AS LotCode,
			--'(01)' + ISNULL(DIST.GTINCode, '') + '(10)' + CONVERT(VARCHAR, Pt.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(Pt.PalletTagNum)) + '00' AS BarCodeNum,

			'(01)' 
					+ 
					dbo.fGTINCode(Sz.GTINCode, St.GTINCode, Va.GTINCode, 
									  Co.GTINCode, DIST.GTINCode)
					+ 
			'(10)' + CONVERT(VARCHAR, Pt.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(Pt.PalletTagNum)) + '00' AS BarCodeNum,

			--CommDesc 8 +?/?+VarietyDesc 8 CommVar
			ISNULL(Co.GTINDescription, '') + '/' + ISNULL(Va.GTINDescription, '') AS CommVar,
			--StyleDesc+SIzeDesc+?,?+?US#1?
			ISNULL(St.GTINDescription, '') + ' ' + ISNULL(Sz.GTINDescription, '') + ', US#1' AS PackWeigthGrade,
			'Product of Mexico' AS FromCty,
			ISNULL(DIST.Owner, '') + ' ' + ISNULL(DIST.Location, '') AS Distributor,
			--ISNULL(DIST.Location, '') AS DistLocation,
			ISNULL(Sz.ItemNum, '') AS ItemNumber,
			Pt.PackedDate AS PackDateOriginal,
			[dbo].[GetDateFormated](Pt.PackedDate) AS PackDate,			
			ISNULL(VoicePick1, '') AS VoicePick1,
			ISNULL(VoicePick2, '') AS VoicePick2,
			ISNULL(SE.QRCodePreFix, '') AS QRCodePreFix,
			CONVERT(VARCHAR, ISNULL(Pt.DestinationID, '0')) AS DestinationID,
			ISNULL(DD.DistributorName, '') AS DistributorName
		FROM PalletTag Pt 
				INNER JOIN  Packer Pk ON 
					Pt.PackerID = Pk.PackerID 
				INNER JOIN Commodity Co ON 
					Pt.CommodityId = Co.CommodityID 
				INNER JOIN CommVariety Va ON 
					Pt.VarietyID = Va.VarietyID 
				INNER JOIN CommStyle St ON 
					Pt.StyleID = St.StyleID 
				INNER JOIN CommSize Sz ON 
					Pt.SizeID = Sz.SizeID 
				INNER JOIN Labels Lb ON 
					Pt.LabelId = Lb.LabelId 
				INNER JOIN Grower AS G ON
					G.GrowerID = Pt.GrowerID
				INNER JOIN Fields AS F ON
					F.FieldID = Pt.FieldID
				INNER JOIN Lots AS L ON
					L.LotID = Pt.LotID
				INNER JOIN Segments AS S ON
					S.SegmentID = Pt.SegmentID
				INNER JOIN Crops AS CR ON
					CR.CropID = Pt.CropID
				LEFT JOIN Seasons AS SE ON
					SE.SeasonID = Pt.SeasonID
				--Joins para obtener datos del formato alternativo
				LEFT JOIN Distributors AS DIST ON
					DIST.DistributorID	=	G.DefaultDistributorID

				LEFT JOIN (SELECT DestinationID, MAX(Owner) AS DistributorName
									 FROM Distributors
									GROUP BY DestinationID) AS DD ON
								DD.DestinationID	= Pt.DestinationID

					
WHERE Pt.CreatedDate BETWEEN ISNULL(@CreatedDate,Pt.CreatedDate) AND  
	  CASE WHEN @CreatedDate IS NULL THEN Pt.CreatedDate ELSE @Siguiente END AND
	  Pt.PalletTagID = ISNULL(@PalletTagID,Pt.PalletTagID)
ORDER By Pt.PreFix, Pt.CreatedDate desc, dbo.PalletTag_ZeroFill(Pt.PalletTagNum)

_GO_


ALTER PROCEDURE [dbo].[PalletTagGetByPalletTagNum]
@PackerID		INT,
@GrowerID		INT,
@PalletTagNum	VARCHAR(50),
@DistributorID INT = NULL
AS

DECLARE
@Season	INT


SET @Season = (SELECT TOP 1 SeasonID FROM Seasons WHERE Default_Season = 1)

IF (SELECT COUNT(*) AS Records
		FROM Company
		WHERE ISNULL(HasDestinations, 0) =  1) > 0
BEGIN
		
		SET @Season = (SELECT TOP 1 DistSeasonID 
										FROM Distributors AS D
											INNER JOIN DistributorSeasons AS S ON
												S.DistributorID	=	D.DistributorID
										WHERE S.Default_Season = 1 AND
													D.DistributorID	=	@DistributorID)


SELECT PT.PalletTagID, PT.SeasonID, 
		PT.PackerID, PackerName,
		PT.GrowerID, GrowerShDesc,
		PT.CommodityID, CommDesc,
		PT.VarietyID, VarDesc,
		PT.StyleID, StyleDesc,
		PT.SizeID, SizeDesc,
		PT.LabelID, LabelDesc,
		PT.FieldID, FldDesc,
		PT.SegmentID, SegDesc,
		PT.LotID, LotDesc,
		PT.CropID, CropDesc,
		PT.IsChep,
		PT.HarvestDate,
		PT.PackedDate,
		PT.PakedByID,
		PT.Pkgs, PT.PkgsShp, PT.Status, PT.CreatedDate, PT.UpDatedByID, PT.PreFix, 
		dbo.PalletTag_ZeroFill(PT.PalletTagNum) AS PalletTagNum, PT.CreatedByID, PT.OverWeight,
		CustomPrice,
		ISNULL(PT.DestinationID, 0) AS DestinationID
	FROM PalletTag AS PT
		INNER JOIN Packer AS P ON
			P.PackerID = PT.PackerID
		INNER JOIN Grower AS G ON
			G.GrowerID = PT.GrowerID
		INNER JOIN Commodity AS C ON
			C.CommodityID = PT.CommodityID
		INNER JOIN CommVariety AS CV ON
			CV.CommodityID = PT.CommodityID
		INNER JOIN CommStyle AS S ON
			S.StyleID = PT.StyleID
		INNER JOIN CommSize AS SI ON
			SI.SizeID = PT.SizeID
		INNER JOIN Labels AS L ON
			L.LabelID = PT.LabelID
		INNER JOIN Fields AS F ON
			F.FieldID	= PT.FieldID
		INNER JOIN Segments AS SEG ON
			SEG.SegmentID = PT.SegmentID
		INNER JOIN Lots AS LOT ON
			LOT.LotID	= PT.LotID
		INNER JOIN Crops AS CR ON
			CR.CropID = PT.CropID

WHERE CONVERT(VARCHAR, PT.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(PT.PalletTagNum)) = @PalletTagNum AND
	  PT.PackerID	=	@PackerID	AND
	  PT.GrowerID	=	@GrowerID AND
	  PT.SeasonID	=	@Season




SELECT M.ManifestID, M.SeasonID, M.ShpDate, M.Seq, M.Status, M.PackerID, M.GrowerID, M.GroReference, M.InvoiceNum, M.DistriburorID, 
		M.MxCustoBkID, M.UsCustoBkID, M.Driver, M.MaintainTemHi, M.MaintainTemLo, M.TransporterID, M.Trailer, M.TruckLic,
		M.TrailerLic, M.DriverLic, M.SecSeal, M.Freight, M.FreightPdByDist, M.PayToName, M.Currency, M.CancelDate, M.Notes,
		M.UpDatedByID, M.LastUpDate, 
		CONVERT(VARCHAR, M.OriginalVersion) as OriginalVersion, 
		M.LdTemp, ISNULL(SCACCode, '') AS SCACCode
	FROM ManifPT AS P
		INNER JOIN	ManifHD AS M ON
			M.ManifestID = P.ManifestID		
	WHERE P.PalletTagID = (SELECT TOP 1 PalletTagID FROM PalletTag AS PT
						WHERE CONVERT(VARCHAR, PT.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(PT.PalletTagNum)) = @PalletTagNum AND PT.SeasonID	=	@Season)
						
						
						
SELECT PT.PackerID, PackerName,
		PT.GrowerID, GrowerShDesc
	FROM PalletTag AS PT
		INNER JOIN Packer AS P ON
			P.PackerID = PT.PackerID
		INNER JOIN Grower AS G ON
			G.GrowerID = PT.GrowerID
WHERE CONVERT(VARCHAR, PT.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(PT.PalletTagNum)) = @PalletTagNum AND PT.SeasonID	=	@Season

END
ELSE
BEGIN

SELECT PT.PalletTagID, PT.SeasonID, 
		PT.PackerID, PackerName,
		PT.GrowerID, GrowerShDesc,
		PT.CommodityID, CommDesc,
		PT.VarietyID, VarDesc,
		PT.StyleID, StyleDesc,
		PT.SizeID, SizeDesc,
		PT.LabelID, LabelDesc,
		PT.FieldID, FldDesc,
		PT.SegmentID, SegDesc,
		PT.LotID, LotDesc,
		PT.CropID, CropDesc,
		PT.IsChep,
		PT.HarvestDate,
		PT.PackedDate,
		PT.PakedByID,
		PT.Pkgs, PT.PkgsShp, PT.Status, PT.CreatedDate, PT.UpDatedByID, PT.PreFix, 
		dbo.PalletTag_ZeroFill(PT.PalletTagNum) AS PalletTagNum, PT.CreatedByID, PT.OverWeight,
		CustomPrice,
		ISNULL(PT.DestinationID, 0) AS DestinationID
	FROM PalletTag AS PT
		INNER JOIN Packer AS P ON
			P.PackerID = PT.PackerID
		INNER JOIN Grower AS G ON
			G.GrowerID = PT.GrowerID
		INNER JOIN Commodity AS C ON
			C.CommodityID = PT.CommodityID
		INNER JOIN CommVariety AS CV ON
			CV.CommodityID = PT.CommodityID
		INNER JOIN CommStyle AS S ON
			S.StyleID = PT.StyleID
		INNER JOIN CommSize AS SI ON
			SI.SizeID = PT.SizeID
		INNER JOIN Labels AS L ON
			L.LabelID = PT.LabelID
		INNER JOIN Fields AS F ON
			F.FieldID	= PT.FieldID
		INNER JOIN Segments AS SEG ON
			SEG.SegmentID = PT.SegmentID
		INNER JOIN Lots AS LOT ON
			LOT.LotID	= PT.LotID
		INNER JOIN Crops AS CR ON
			CR.CropID = PT.CropID

WHERE CONVERT(VARCHAR, PT.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(PT.PalletTagNum)) = @PalletTagNum AND
	  PT.PackerID	=	@PackerID	AND
	  PT.GrowerID	=	@GrowerID AND
	  PT.SeasonID	=	@Season




SELECT M.ManifestID, M.SeasonID, M.ShpDate, M.Seq, M.Status, M.PackerID, M.GrowerID, M.GroReference, M.InvoiceNum, M.DistriburorID, 
		M.MxCustoBkID, M.UsCustoBkID, M.Driver, M.MaintainTemHi, M.MaintainTemLo, M.TransporterID, M.Trailer, M.TruckLic,
		M.TrailerLic, M.DriverLic, M.SecSeal, M.Freight, M.FreightPdByDist, M.PayToName, M.Currency, M.CancelDate, M.Notes,
		M.UpDatedByID, M.LastUpDate, 
		CONVERT(VARCHAR, M.OriginalVersion) as OriginalVersion, 
		M.LdTemp, ISNULL(SCACCode, '') AS SCACCode
	FROM ManifPT AS P
		INNER JOIN	ManifHD AS M ON
			M.ManifestID = P.ManifestID		
	WHERE P.PalletTagID = (SELECT TOP 1 PalletTagID FROM PalletTag AS PT
						WHERE CONVERT(VARCHAR, PT.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(PT.PalletTagNum)) = @PalletTagNum AND PT.SeasonID	=	@Season)
						
						
						
SELECT PT.PackerID, PackerName,
		PT.GrowerID, GrowerShDesc
	FROM PalletTag AS PT
		INNER JOIN Packer AS P ON
			P.PackerID = PT.PackerID
		INNER JOIN Grower AS G ON
			G.GrowerID = PT.GrowerID
WHERE CONVERT(VARCHAR, PT.PreFix) + CONVERT(VARCHAR, dbo.PalletTag_ZeroFill(PT.PalletTagNum)) = @PalletTagNum AND PT.SeasonID	=	@Season
END

SELECT * 
FROM Distributors
WHERE DistributorID	=	 @DistributorID

SELECT TOP 1 ISNULL(HasDestinations, 0) AS HasDestinations FROM Company

_GO_

ALTER PROCEDURE [dbo].[ManifHGUpdateByStatus]
@DistributorID INT,
@Status		INT

AS

UPDATE ManifHD SET
Status	=	3
WHERE Status = 1
	AND DistriburorID = @DistributorID

_GO_


/******************************************************************/
--TEMPORADA DEL DISTRIBUIDOR
--Query, De las palletas que ya estan, cuando se vaya a definir la temporada
--del distribuidor DEFAULT, correr este query, el cual tomara las palletas
--actuales y les pondra el seasonID de la temporada del distribuidor.

--Actualiza el destinationID correspondiente al distribuidor base
SELECT * FROM Distributors
UPDATE PalletTag SET
DestinationID = 1

--Busco el SeasonID de la temporada default del distribuidor
SELECT * 
FROM Distributors AS D
	INNER JOIN DistributorSeasons AS S ON
		S.DistributorID	=	D.DistributorID
WHERE D.DistributorID = 1

--Actualiza el SeasonID de la temporada default del distribuidor
UPDATE PalletTag SET
	SeasonID = 5

/******************************************************************/


