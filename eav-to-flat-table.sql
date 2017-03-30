BEGIN TRANSACTION

/*
	CREATE TABLES
*/

CREATE TABLE Products (
    Id int identity(1,1),
    Name NVarchar(255),
    PRIMARY KEY (ID)
);

CREATE TABLE ProductProperty (
    Id int identity(1,1),
	ProductId int NOT NULL,
    Name NVarchar(255) NOT NULL,
    [Value] NVarchar(max) NULL
    PRIMARY KEY (ID),
	FOREIGN KEY (ProductId) REFERENCES Products(Id)
);

/*
	FILL TABLES
*/
INSERT INTO Products VALUES ('Ladder')
INSERT INTO Products VALUES ('Painting')

INSERT INTO ProductProperty (ProductId, Name, [Value]) VALUES (1, 'Height', '3m')
INSERT INTO ProductProperty (ProductId, Name, [Value]) VALUES (1, 'Width', '0.5m')
INSERT INTO ProductProperty (ProductId, Name, [Value]) VALUES (1, 'Brand', 'Bailey Ladders')
INSERT INTO ProductProperty (ProductId, Name, [Value]) VALUES (2, 'Color', 'Red')
INSERT INTO ProductProperty (ProductId, Name, [Value]) VALUES (2, 'Brand', 'Brand Painting Co')

/*
	PIVOT
*/

DECLARE @allKeys NVARCHAR(100)
DECLARE @query NVARCHAR(MAX)

-- Get all attributes names that we'll use as column names
SET @allKeys = STUFF
    (
        (
            SELECT ',' + QUOTENAME(p.Name) 
            FROM (
				SELECT DISTINCT Name
				FROM ProductProperty
			) p
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)') 
        ,1,1,''
    )

SELECT	p.Id 'ProductId', 
		p.Name 'ProductName',
		pp.Id 'ProductPropertyId',
		pp.Name 'ProductPropertyName',
		pp.[Value] 'ProductPropertyValue'
FROM ProductProperty pp
INNER JOIN Products p ON pp.ProductId = p.Id

-- Build the main query
SET @query = '	 SELECT	* 
                 FROM 
                 (
					SELECT pp.Name, 
						   pp.[Value], 
						   p.Id ''ProductId'', 
						   p.Name ''ProductName''
					FROM ProductProperty pp
					INNER JOIN Products p ON pp.ProductId = p.Id
				 ) x
                 pivot 
                 (
                    max(x.[Value])
                    for x.Name in (' + @allKeys + ')
                 ) p '


EXECUTE(@query)​



ROLLBACK TRANSACTION