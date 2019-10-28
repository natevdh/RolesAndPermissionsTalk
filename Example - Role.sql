ALTER ROLE [Sales Manager] ADD MEMBER [SalesManagerExample]
ALTER ROLE [Mideast Sales] ADD MEMBER [MideastSalesExample]
ALTER ROLE [New England Sales] ADD MEMBER [NewEnglandSalesExample]

ALTER ROLE [New England Sales] ADD MEMBER [MultiSalesExample]
ALTER ROLE [Mideast Sales] ADD MEMBER [MultiSalesExample]

ALTER ROLE [SalesDept] ADD MEMBER [Sales Manager]
ALTER ROLE [SalesDept] ADD MEMBER [Mideast Sales]
ALTER ROLE [SalesDept] ADD MEMBER [New England Sales]





EXECUTE AS USER = 'SalesManagerExample'
GO
SELECT * FROM Application.Cities c
GO
REVERT
GO


GRANT SELECT ON Application.Cities TO SalesDept
GO
EXECUTE AS USER = 'SalesManagerExample'
GO
SELECT * FROM Application.Cities c
GO
REVERT
GO