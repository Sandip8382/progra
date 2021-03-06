USE [cmsSericulture]
GO
/****** Object:  UserDefinedTableType [dbo].[ReferenceApplicationRights]    Script Date: 08-05-2021 11:58:32 ******/
CREATE TYPE [dbo].[ReferenceApplicationRights] AS TABLE(
	[Role] [varchar](10) NULL,
	[MenuId] [int] NULL,
	[Status] [bit] NULL,
	[AllowInsert] [bit] NULL,
	[AllowDelete] [bit] NULL,
	[AllowUpdate] [bit] NULL,
	[AllowPublish] [bit] NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Split]    Script Date: 08-05-2021 11:58:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  FUNCTION [dbo].[fn_Split](@text varchar(8000), @delimiter varchar(20) = ' ')
RETURNS @Strings TABLE
(   
  position int IDENTITY PRIMARY KEY,
  value varchar(8000)  
)
AS
BEGIN
 
DECLARE @index int
SET @index = -1

WHILE (LEN(@text) > 0)
  BEGIN 
    SET @index = CHARINDEX(@delimiter , @text) 
    IF (@index = 0) AND (LEN(@text) > 0) 
      BEGIN  
        INSERT INTO @Strings VALUES (@text)
          BREAK 
      END 
    IF (@index > 1) 
      BEGIN  
        INSERT INTO @Strings VALUES (LEFT(@text, @index - 1))  
        SET @text = RIGHT(@text, (LEN(@text) - @index)) 
      END 
    ELSE
      SET @text = RIGHT(@text, (LEN(@text) - @index))
    END
  RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[MenuList]    Script Date: 08-05-2021 11:58:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE function [dbo].[MenuList](@PageName varchar(50))    
RETURNS @Strings TABLE    
(       
  menuEnglish nvarchar(max),      
  menuHindi nvarchar(max)      
)       
AS                         
begin                                         
declare @MenuId nvarchar(max)                                                   
declare @SubMenuId nvarchar(max)                                                   
declare @Menulist nvarchar(max)                                                   
declare @MenulistHindi nvarchar(max)                                                   
declare @Ul nvarchar(max)  ,@li nvarchar(max),@Subli nvarchar(max)  ,                  
@SubUl nvarchar(max)  ,@SubliLink nvarchar(max) ,@SubMegaMenuLI nvarchar(max)  ,                  
@SubMegaMenuHtmlUl nvarchar(max)                                                        
      Set @li='<li class="nav-item"><a href="'                                          
      Set @SubUl=' <li class="nav-item side_list_group"><a href="#">'                                          
      Set @Subli='</a><ul class="side_links" style="display: none;">'                                        
      Set @SubliLink=' <li><a href="'                                        
                                    
(Select top 1 @SubMenuId=MenuId,  @MenuId=(case when m.ParentId is null then MenuId else m.ParentId end) from cmsPublicMenuPublish m left join   
cmsPages p on m.PageId=p.PageId where PageName=@PageName)      

(Select top 1 @MenuId=(case when ParentId is null then MenuId else ParentId end) from 
cmsPublicMenuPublish  where MenuId=@MenuId)      


                        
BEGIN --English Menu                    
SELECT                                                                                         
@Menulist=isnull((                                        
                                        
SELECT                                          
case when (select COUNT(*) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>0 then                                    
                                        
--@SubUl+ MainMenu.MenuName+'+'+@Subli+                               
(                              
SELECT                               
(case when (select COUNT(*) from cmsPublicMenuPublish subSub where ParentId=SubMenu.MenuId and Status='P')>0 then                                
(                              
@SubUl+SubMenu.MenuName+' <i class="fas fa-plus"></i>'+@Subli+                                     
(SELECT @SubliLink+           
(case when subOfSub.LinkType='Url' then ISNULL(subOfSub.Path,'#') else  ISNULL(pSubOfSubPage.PageName,'#') end)          
+'" target="'+ISNULL(subOfSub.Target,'')+'" 
 class="'+case when @SubMenuId=subOfSub.MenuId then 'active' else '' end+'">' +subOfSub.MenuName+'</a></li>' from cmsPublicMenuPublish subOfSub                              
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId                                  
 where ParentId=SubMenu.MenuId        and subOfSub.Status='P'                                  
order by  Priority asc,ParentId, MenuId                                                     
FOR XML PATH('')) +'</ul></li>'                                  
                              
                              
                              
) else                               
                              
@SubliLink+(case when SubMenu.LinkType='Url' then ISNULL(SubMenu.Path,'#') else ISNULL(pSubPage.PageName,'#') end)          
+'" target="'+ISNULL(SubMenu.Target,'')+'" 
 class="'+case when @SubMenuId=SubMenu.MenuId then 'active' else '' end+'">' +SubMenu.MenuName+'</a></li>'  end)                              
                              
                              
from cmsPublicMenuPublish SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId                                  
where ParentId=MainMenu.MenuId   and SubMenu.Status='P'                                        
                              
                              
                              
order by  Priority asc,ParentId, MenuId                                                     
FOR XML PATH('')) +'</ul></li>'                                        
                                        
else @li+(case when MainMenu.LinkType='Url' then ISNULL(MainMenu.Path,'#') else ISNULL(pMainPage.PageName,'#') end)          
          
+'" target="'+ISNULL(MainMenu.Target,'')+'"
 class="'+case when @SubMenuId=MainMenu.MenuId then 'active' else '' end+'">' +MainMenu.MenuName+'</a></li>'   end  as MenuName                  
                                        
from cmsPublicMenuPublish MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId                                  
                                  
                  
where MainMenu.ParentId is null     and MainMenu.Status='P'  and MainMenu.MenuId=@MenuId                                  
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                                            
  FOR XML PATH('')                                        
                                        
),'')               
     END                       
                    
  BEGIN -- HINDI MENU                    
SELECT                                                                                         
@MenulistHindi=isnull((                                                                  
SELECT                                          
case when (select COUNT(*) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>0 then                                    
                                   
--@SubUl+ MainMenu.MenuNameHindi+'+'+@Subli+                               
(                              
                              
SELECT                               
(case when (select COUNT(*) from cmsPublicMenuPublish subSub where ParentId=SubMenu.MenuId and Status='P')>0 then                                
(                              
                              
@SubUl+SubMenu.MenuNameHindi+' <i class="fas fa-plus"></i>'+@Subli+                                     
(SELECT @SubliLink+(case when subOfSub.LinkType='Url' then ISNULL(subOfSub.Path,'#') else  ISNULL(pSubOfSubPage.PageName,'#') end)          
+'" target="'+ISNULL(subOfSub.Target,'')+'"
 class="'+case when @SubMenuId=subOfSub.MenuId then 'active' else '' end+'">' +subOfSub.MenuNameHindi+'</a></li>' from cmsPublicMenuPublish subOfSub                              
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId                                  
                              
 where ParentId=SubMenu.MenuId    and subOfSub.Status='P'                                      
order by  Priority asc,ParentId, MenuId                                                     
FOR XML PATH('')) +'</ul></li>'                                  
                         
                              
                              
) else                               
                              
@SubliLink+(case when SubMenu.LinkType='Url' then ISNULL(SubMenu.Path,'#') else  ISNULL(pSubPage.PageName,'#') End)          
          
+'" target="'+ISNULL(SubMenu.Target,'')+'"
 class="'+case when @SubMenuId=SubMenu.MenuId then 'active' else '' end+'">' +SubMenu.MenuNameHindi+'</a></li>'  end)                              
                              
                              
from cmsPublicMenuPublish SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId                                  
where ParentId=MainMenu.MenuId        and SubMenu.Status='P'                                   
                              
                              
                              
order by  Priority asc,ParentId, MenuId                                                     
FOR XML PATH('')) +'</ul></li>'                                 
                                        
else @li+(case when MainMenu.LinkType='Url' then ISNULL(MainMenu.Path,'#') else  ISNULL(pMainPage.PageName,'#') End)          
+'" target="'+ISNULL(MainMenu.Target,'')+'"
 class="'+case when @SubMenuId=MainMenu.MenuId then 'active' else '' end+'">' +MainMenu.MenuNameHindi+'</a></li>'   end  as MenuName                                        
                                        
from cmsPublicMenuPublish MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId                                  
where MainMenu.ParentId is null     and MainMenu.Status='P'  and MainMenu.MenuId=@MenuId                                     
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                                                   
  FOR XML PATH('')                                        
                                        
),'')                                 
        END                    
                    
        
               
   INSERT INTO @Strings VALUES (@Menulist,@MenulistHindi)    
   Return     
   End    
    
GO
/****** Object:  Table [dbo].[AppExceptionLog]    Script Date: 08-05-2021 11:58:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppExceptionLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ExceptionMsg] [nvarchar](max) NULL,
	[ControllerName] [nvarchar](100) NULL,
	[ActionName] [nvarchar](100) NULL,
	[Other] [nvarchar](max) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[ProcName] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationUser]    Script Date: 08-05-2021 11:58:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](50) NOT NULL,
	[Password] [varchar](100) NULL,
	[RoleId] [smallint] NULL,
	[DepartmentId] [varchar](1000) NULL,
	[Role] [nvarchar](50) NULL,
	[EmployeeId] [int] NULL,
	[MobileNo] [varchar](50) NULL,
	[UserName] [nvarchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[OfficeType] [nvarchar](50) NULL,
	[OfficeId] [smallint] NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[LastUpdatedBy] [varchar](50) NULL,
	[LastLoginDateTime] [datetime] NULL,
	[LastLoginIPAddress] [varchar](50) NULL,
	[CurrentIPAddress] [varchar](50) NULL,
	[CurrentLoginDateTime] [datetime] NULL,
	[isBlock] [bit] NULL,
 CONSTRAINT [PK_LoginDetails] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationUser_History]    Script Date: 08-05-2021 11:58:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationUser_History](
	[Id] [int] NOT NULL,
	[UserId] [nvarchar](50) NOT NULL,
	[Password] [varchar](100) NULL,
	[DepartmentId] [varchar](1000) NULL,
	[RoleId] [smallint] NULL,
	[Role] [nvarchar](50) NULL,
	[EmployeeId] [int] NULL,
	[MobileNo] [varchar](50) NULL,
	[UserName] [nvarchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[OfficeType] [nvarchar](50) NULL,
	[OfficeId] [smallint] NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[LastUpdatedBy] [varchar](50) NULL,
	[LastLoginDateTime] [datetime] NULL,
	[LastLoginIPAddress] [varchar](50) NULL,
	[CurrentIPAddress] [varchar](50) NULL,
	[CurrentLoginDateTime] [datetime] NULL,
	[isBlock] [bit] NULL,
	[ActionType] [nvarchar](200) NULL,
	[ActionOn] [datetime] NULL,
	[ActionBy] [nvarchar](200) NULL,
	[ActionIPAddress] [nvarchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationUserLog]    Script Date: 08-05-2021 11:58:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApplicationUserLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](50) NULL,
	[LogType] [nvarchar](200) NULL,
	[LogOn] [datetime] NULL,
	[Logby] [nvarchar](50) NULL,
	[LogIPAddress] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsApplicationDetails]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsApplicationDetails](
	[MenuId] [int] IDENTITY(1,1) NOT NULL,
	[ModuleId] [int] NULL,
	[MenuName] [nvarchar](500) NULL,
	[ParentId] [int] NULL,
	[PageName] [nvarchar](500) NULL,
	[PageFor] [varchar](50) NULL,
	[Status] [char](1) NULL,
	[Priority] [int] NULL,
	[ActionName] [varchar](500) NULL,
	[AllowInsert] [bit] NULL,
	[AllowDelete] [bit] NULL,
	[AllowUpdate] [bit] NULL,
	[AllowPublish] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsApplicationRights]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsApplicationRights](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Role] [char](1) NULL,
	[MenuId] [int] NULL,
	[Status] [char](1) NULL,
	[AllowInsert] [bit] NULL,
	[AllowDelete] [bit] NULL,
	[AllowUpdate] [bit] NULL,
	[AllowPublish] [bit] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[IPAddress] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsCareer]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsCareer](
	[CareerId] [int] IDENTITY(1,1) NOT NULL,
	[nameOfOrganization] [varchar](200) NULL,
	[typeOfOrganization] [varchar](100) NULL,
	[vacancyTitle] [nvarchar](max) NULL,
	[vacancyRefNo] [varchar](200) NULL,
	[productCategory] [varchar](200) NULL,
	[subCategory] [varchar](200) NULL,
	[vacancyValueType] [varchar](100) NULL,
	[vacancyValue] [varchar](100) NULL,
	[emd] [varchar](100) NULL,
	[documentCost] [varchar](100) NULL,
	[vacancyType] [varchar](100) NULL,
	[biddingType] [varchar](100) NULL,
	[limited] [varchar](100) NULL,
	[location] [varchar](100) NULL,
	[firstAnnouncementDate] [varchar](100) NULL,
	[lastDateOfCollection] [varchar](100) NULL,
	[lastDateForSubmission] [varchar](100) NULL,
	[openingDate] [varchar](100) NULL,
	[workDescription] [nvarchar](max) NULL,
	[preQualification] [nvarchar](max) NULL,
	[preBidMeet] [varchar](100) NULL,
	[vacancyDocument] [varchar](100) NULL,
	[vacancyDocument1] [varchar](100) NULL,
	[vacancyDocument2] [varchar](100) NULL,
	[vacancyDocument3] [varchar](100) NULL,
	[vacancyDocument4] [varchar](100) NULL,
	[vacancyDocument5] [varchar](100) NULL,
	[vacancyDocument6] [varchar](100) NULL,
	[vacancyDocument7] [varchar](100) NULL,
	[extradoc] [varchar](100) NULL,
	[extradoc1] [varchar](100) NULL,
	[extradoc2] [varchar](100) NULL,
	[vacancyDocumentExtra] [varchar](200) NULL,
	[hindiDocs] [varchar](100) NULL,
	[linkName] [varchar](200) NULL,
	[linkName1] [varchar](200) NULL,
	[linkName2] [varchar](200) NULL,
	[linkName3] [varchar](200) NULL,
	[linkName4] [varchar](200) NULL,
	[format1] [varchar](100) NULL,
	[format2] [varchar](100) NULL,
	[format3] [varchar](100) NULL,
	[format4] [varchar](100) NULL,
	[format5] [varchar](100) NULL,
	[createDate] [datetime] NULL,
	[modifyDate] [datetime] NULL,
	[status] [varchar](100) NULL,
	[depName] [varchar](200) NULL,
	[recievingDate] [varchar](100) NULL,
	[assignTo] [varchar](100) NULL,
	[descriptionOfAssign] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsCareer] PRIMARY KEY CLUSTERED 
(
	[CareerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsCareer_History]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsCareer_History](
	[CareerId] [int] NULL,
	[nameOfOrganization] [varchar](200) NULL,
	[typeOfOrganization] [varchar](100) NULL,
	[vacancyTitle] [nvarchar](max) NULL,
	[vacancyRefNo] [varchar](200) NULL,
	[productCategory] [varchar](200) NULL,
	[subCategory] [varchar](200) NULL,
	[vacancyValueType] [varchar](100) NULL,
	[vacancyValue] [varchar](100) NULL,
	[emd] [varchar](100) NULL,
	[documentCost] [varchar](100) NULL,
	[vacancyType] [varchar](100) NULL,
	[biddingType] [varchar](100) NULL,
	[limited] [varchar](100) NULL,
	[location] [varchar](100) NULL,
	[firstAnnouncementDate] [varchar](100) NULL,
	[lastDateOfCollection] [varchar](100) NULL,
	[lastDateForSubmission] [varchar](100) NULL,
	[openingDate] [varchar](100) NULL,
	[workDescription] [nvarchar](max) NULL,
	[preQualification] [nvarchar](max) NULL,
	[preBidMeet] [varchar](100) NULL,
	[vacancyDocument] [varchar](100) NULL,
	[vacancyDocument1] [varchar](100) NULL,
	[vacancyDocument2] [varchar](100) NULL,
	[vacancyDocument3] [varchar](100) NULL,
	[vacancyDocument4] [varchar](100) NULL,
	[vacancyDocument5] [varchar](100) NULL,
	[vacancyDocument6] [varchar](100) NULL,
	[vacancyDocument7] [varchar](100) NULL,
	[extradoc] [varchar](100) NULL,
	[extradoc1] [varchar](100) NULL,
	[extradoc2] [varchar](100) NULL,
	[vacancyDocumentExtra] [varchar](200) NULL,
	[hindiDocs] [varchar](100) NULL,
	[linkName] [varchar](200) NULL,
	[linkName1] [varchar](200) NULL,
	[linkName2] [varchar](200) NULL,
	[linkName3] [varchar](200) NULL,
	[linkName4] [varchar](200) NULL,
	[format1] [varchar](100) NULL,
	[format2] [varchar](100) NULL,
	[format3] [varchar](100) NULL,
	[format4] [varchar](100) NULL,
	[format5] [varchar](100) NULL,
	[createDate] [datetime] NULL,
	[modifyDate] [datetime] NULL,
	[status] [varchar](100) NULL,
	[depName] [varchar](200) NULL,
	[recievingDate] [varchar](100) NULL,
	[assignTo] [varchar](100) NULL,
	[descriptionOfAssign] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsCareerPublish]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsCareerPublish](
	[CareerId] [int] NOT NULL,
	[nameOfOrganization] [varchar](200) NULL,
	[typeOfOrganization] [varchar](100) NULL,
	[vacancyTitle] [nvarchar](max) NULL,
	[vacancyRefNo] [varchar](200) NULL,
	[productCategory] [varchar](200) NULL,
	[subCategory] [varchar](200) NULL,
	[vacancyValueType] [varchar](100) NULL,
	[vacancyValue] [varchar](100) NULL,
	[emd] [varchar](100) NULL,
	[documentCost] [varchar](100) NULL,
	[vacancyType] [varchar](100) NULL,
	[biddingType] [varchar](100) NULL,
	[limited] [varchar](100) NULL,
	[location] [varchar](100) NULL,
	[firstAnnouncementDate] [varchar](100) NULL,
	[lastDateOfCollection] [varchar](100) NULL,
	[lastDateForSubmission] [varchar](100) NULL,
	[openingDate] [varchar](100) NULL,
	[workDescription] [nvarchar](max) NULL,
	[preQualification] [nvarchar](max) NULL,
	[preBidMeet] [varchar](100) NULL,
	[vacancyDocument] [varchar](100) NULL,
	[vacancyDocument1] [varchar](100) NULL,
	[vacancyDocument2] [varchar](100) NULL,
	[vacancyDocument3] [varchar](100) NULL,
	[vacancyDocument4] [varchar](100) NULL,
	[vacancyDocument5] [varchar](100) NULL,
	[vacancyDocument6] [varchar](100) NULL,
	[vacancyDocument7] [varchar](100) NULL,
	[extradoc] [varchar](100) NULL,
	[extradoc1] [varchar](100) NULL,
	[extradoc2] [varchar](100) NULL,
	[vacancyDocumentExtra] [varchar](200) NULL,
	[hindiDocs] [varchar](100) NULL,
	[linkName] [varchar](200) NULL,
	[linkName1] [varchar](200) NULL,
	[linkName2] [varchar](200) NULL,
	[linkName3] [varchar](200) NULL,
	[linkName4] [varchar](200) NULL,
	[format1] [varchar](100) NULL,
	[format2] [varchar](100) NULL,
	[format3] [varchar](100) NULL,
	[format4] [varchar](100) NULL,
	[format5] [varchar](100) NULL,
	[createDate] [datetime] NULL,
	[modifyDate] [datetime] NULL,
	[status] [varchar](100) NULL,
	[depName] [varchar](200) NULL,
	[recievingDate] [varchar](100) NULL,
	[assignTo] [varchar](100) NULL,
	[descriptionOfAssign] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UIPAddress] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsClone]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsClone](
	[CloneId] [bigint] IDENTITY(1,1) NOT NULL,
	[CloneTitle] [nvarchar](500) NULL,
	[CloneContent] [nvarchar](max) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsClone] PRIMARY KEY CLUSTERED 
(
	[CloneId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsCompainOrFeedback]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsCompainOrFeedback](
	[ComplainId] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[Address] [nvarchar](500) NULL,
	[UploadFileName] [varchar](200) NULL,
	[ComplainType] [nvarchar](100) NULL,
	[ComplainSubject] [nvarchar](500) NULL,
	[ComplainContent] [nvarchar](1000) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsCompainOrFeedback] PRIMARY KEY CLUSTERED 
(
	[ComplainId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsComplainOrFeedback_History]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsComplainOrFeedback_History](
	[ComplainId] [bigint] NOT NULL,
	[ComplainType] [nvarchar](100) NULL,
	[ComplainSubject] [nvarchar](500) NULL,
	[ComplainContent] [nvarchar](1000) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsDepartment]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsDepartment](
	[DepartmentId] [bigint] IDENTITY(1,1) NOT NULL,
	[DepartmentType] [nvarchar](100) NULL,
	[DepartmentName] [nvarchar](100) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsDepartment] PRIMARY KEY CLUSTERED 
(
	[DepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsDepartment_History]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsDepartment_History](
	[DepartmentId] [bigint] NOT NULL,
	[DepartmentType] [nvarchar](100) NULL,
	[DepartmentName] [nvarchar](100) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsFaQ]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsFaQ](
	[FaqId] [bigint] IDENTITY(1,1) NOT NULL,
	[QuestionCategoryhindi] [nvarchar](500) NULL,
	[QuestionCategory] [nvarchar](500) NULL,
	[QuestionHindi] [nvarchar](max) NULL,
	[Question] [nvarchar](max) NULL,
	[AnswerHindi] [nvarchar](max) NULL,
	[Answer] [nvarchar](max) NULL,
	[AnswerDate] [datetime] NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsFaQ] PRIMARY KEY CLUSTERED 
(
	[FaqId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsFaq_History]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsFaq_History](
	[FaqId] [bigint] NULL,
	[QuestionCategoryhindi] [nvarchar](500) NULL,
	[QuestionCategory] [nvarchar](500) NULL,
	[QuestionHindi] [nvarchar](max) NULL,
	[Question] [nvarchar](max) NULL,
	[AnswerHindi] [nvarchar](500) NULL,
	[Answer] [nvarchar](500) NULL,
	[AnswerDate] [datetime] NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsFaqPublish]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsFaqPublish](
	[FaqId] [bigint] NOT NULL,
	[QuestionCategoryhindi] [nvarchar](500) NULL,
	[QuestionCategory] [nvarchar](500) NULL,
	[QuestionHindi] [nvarchar](max) NULL,
	[Question] [nvarchar](max) NULL,
	[AnswerHindi] [nvarchar](max) NULL,
	[Answer] [nvarchar](max) NULL,
	[AnswerDate] [datetime] NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsFaqPublish] PRIMARY KEY CLUSTERED 
(
	[FaqId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsMainSite]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMainSite](
	[MainSiteId] [bigint] IDENTITY(1,1) NOT NULL,
	[ThemeName] [varchar](200) NULL,
	[HeadTag] [nvarchar](max) NULL,
	[FooterScript] [nvarchar](max) NULL,
	[Header] [nvarchar](max) NULL,
	[HeaderHindi] [nvarchar](max) NULL,
	[BeforeManuHeader] [nvarchar](max) NULL,
	[AfterManuHeader] [nvarchar](max) NULL,
	[Breadcrumbs] [nvarchar](max) NULL,
	[InnerPageStart] [nvarchar](max) NULL,
	[InnerPageEnd] [nvarchar](max) NULL,
	[ContentStart] [nvarchar](max) NULL,
	[ContenEnd] [nvarchar](max) NULL,
	[Footer] [nvarchar](max) NULL,
	[FooterHindi] [nvarchar](max) NULL,
	[Body] [nvarchar](max) NULL,
	[Slider] [nvarchar](max) NULL,
	[PublicMenu] [nvarchar](max) NULL,
	[Pages] [nvarchar](max) NULL,
	[MenuHtmlUL] [nvarchar](max) NULL,
	[MenuHtmlLi] [nvarchar](max) NULL,
	[SubMenuHtmlUl] [nvarchar](max) NULL,
	[SubMenuHtmlLi] [nvarchar](max) NULL,
	[SubMenuHtmlLiLink] [nvarchar](max) NULL,
	[MegaMenuHtmlLi] [nvarchar](max) NULL,
	[SubMegaMenuHtmlUl] [nvarchar](max) NULL,
	[StatusPublish] [char](1) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsMainSite] PRIMARY KEY CLUSTERED 
(
	[MainSiteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsMainSite_History]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMainSite_History](
	[MainSiteId] [bigint] NOT NULL,
	[ThemeName] [varchar](200) NULL,
	[HeadTag] [nvarchar](max) NULL,
	[FooterScript] [nvarchar](max) NULL,
	[Header] [nvarchar](max) NULL,
	[HeaderHindi] [nvarchar](max) NULL,
	[BeforeManuHeader] [nvarchar](max) NULL,
	[AfterManuHeader] [nvarchar](max) NULL,
	[Breadcrumbs] [nvarchar](max) NULL,
	[InnerPageStart] [nvarchar](max) NULL,
	[InnerPageEnd] [nvarchar](max) NULL,
	[ContentStart] [nvarchar](max) NULL,
	[ContenEnd] [nvarchar](max) NULL,
	[Footer] [nvarchar](max) NULL,
	[FooterHindi] [nvarchar](max) NULL,
	[Body] [nvarchar](max) NULL,
	[Slider] [nvarchar](max) NULL,
	[PublicMenu] [nvarchar](max) NULL,
	[Pages] [nvarchar](max) NULL,
	[MenuHtmlUL] [nvarchar](max) NULL,
	[MenuHtmlLi] [nvarchar](max) NULL,
	[SubMenuHtmlUl] [nvarchar](max) NULL,
	[SubMenuHtmlLi] [nvarchar](max) NULL,
	[SubMenuHtmlLiLink] [nvarchar](max) NULL,
	[MegaMenuHtmlLi] [nvarchar](max) NULL,
	[SubMegaMenuHtmlUl] [nvarchar](max) NULL,
	[StatusPublish] [char](1) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsMainSitePublish]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMainSitePublish](
	[MainSiteId] [bigint] NULL,
	[ThemeName] [varchar](200) NULL,
	[HeadTag] [nvarchar](max) NULL,
	[FooterScript] [nvarchar](max) NULL,
	[Header] [nvarchar](max) NULL,
	[HeaderHindi] [nvarchar](max) NULL,
	[BeforeManuHeader] [nvarchar](max) NULL,
	[AfterManuHeader] [nvarchar](max) NULL,
	[Breadcrumbs] [nvarchar](max) NULL,
	[InnerPageStart] [nvarchar](max) NULL,
	[InnerPageEnd] [nvarchar](max) NULL,
	[ContentStart] [nvarchar](max) NULL,
	[ContenEnd] [nvarchar](max) NULL,
	[Footer] [nvarchar](max) NULL,
	[FooterHindi] [nvarchar](max) NULL,
	[Body] [nvarchar](max) NULL,
	[Slider] [nvarchar](max) NULL,
	[PublicMenu] [nvarchar](max) NULL,
	[Pages] [nvarchar](max) NULL,
	[MenuHtmlUL] [nvarchar](max) NULL,
	[MenuHtmlLi] [nvarchar](max) NULL,
	[SubMenuHtmlUl] [nvarchar](max) NULL,
	[SubMenuHtmlLi] [nvarchar](max) NULL,
	[SubMenuHtmlLiLink] [nvarchar](max) NULL,
	[MegaMenuHtmlLi] [nvarchar](max) NULL,
	[SubMegaMenuHtmlUl] [nvarchar](max) NULL,
	[StatusPublish] [char](1) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsMediaGallery]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMediaGallery](
	[MediaId] [int] IDENTITY(1,1) NOT NULL,
	[MediaCategory] [varchar](50) NULL,
	[MediaType] [char](1) NULL,
	[MediaTitle] [nvarchar](500) NULL,
	[MediaContent] [nvarchar](500) NULL,
	[MediaTitleHindi] [nvarchar](500) NULL,
	[MediaContentHindi] [nvarchar](500) NULL,
	[MediaPath] [varchar](250) NULL,
	[Version] [varchar](50) NULL,
	[FileSize] [varchar](50) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsMediaGallery_History]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMediaGallery_History](
	[MediaId] [int] NOT NULL,
	[MediaType] [char](1) NULL,
	[MediaTitle] [nvarchar](500) NULL,
	[MediaContent] [nvarchar](500) NULL,
	[MediaPath] [varchar](250) NULL,
	[Status] [char](1) NULL,
	[Version] [varchar](50) NULL,
	[FileSize] [varchar](50) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsMediaGalleryPublish]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMediaGalleryPublish](
	[MediaId] [int] NOT NULL,
	[MediaCategory] [varchar](50) NULL,
	[MediaType] [char](1) NULL,
	[MediaTitle] [nvarchar](500) NULL,
	[MediaContent] [nvarchar](500) NULL,
	[MediaTitleHindi] [nvarchar](500) NULL,
	[MediaContentHindi] [nvarchar](500) NULL,
	[MediaPath] [varchar](250) NULL,
	[Version] [varchar](50) NULL,
	[FileSize] [varchar](50) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsMediaGalleryType]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsMediaGalleryType](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MediaType] [nvarchar](500) NULL,
 CONSTRAINT [PK_cmsMediaGalleryType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsNotification]    Script Date: 08-05-2021 11:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsNotification](
	[NotificationId] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](50) NULL,
	[DescriptionHindi] [nvarchar](3000) NULL,
	[Description] [nvarchar](2000) NULL,
	[ExpiryDate] [date] NULL,
	[StartDate] [date] NULL,
	[Status] [char](1) NULL,
	[PageId] [int] NULL,
	[Path] [varchar](500) NULL,
	[LinkType] [varchar](10) NULL,
	[Target] [varchar](10) NULL,
	[Priority] [varchar](10) NULL,
	[NewGIF] [varchar](200) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsNotification] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsNotification_History]    Script Date: 08-05-2021 11:58:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsNotification_History](
	[NotificationId] [int] NOT NULL,
	[DescriptionHindi] [nvarchar](3000) NULL,
	[Description] [nvarchar](2000) NULL,
	[ExpiryDate] [date] NULL,
	[StartDate] [date] NULL,
	[Status] [char](1) NULL,
	[Type] [varchar](50) NULL,
	[PageId] [int] NULL,
	[Path] [varchar](500) NULL,
	[LinkType] [varchar](10) NULL,
	[Target] [varchar](10) NULL,
	[Priority] [varchar](10) NULL,
	[NewGIF] [varchar](200) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsNotificationPublish]    Script Date: 08-05-2021 11:58:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsNotificationPublish](
	[NotificationId] [bigint] NOT NULL,
	[Type] [varchar](50) NULL,
	[DescriptionHindi] [nvarchar](3000) NULL,
	[Description] [nvarchar](2000) NULL,
	[ExpiryDate] [date] NULL,
	[StartDate] [date] NULL,
	[PageId] [int] NULL,
	[Path] [varchar](500) NULL,
	[LinkType] [varchar](10) NULL,
	[Target] [varchar](10) NULL,
	[Priority] [varchar](10) NULL,
	[NewGIF] [varchar](200) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsPages]    Script Date: 08-05-2021 11:58:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPages](
	[PageId] [bigint] IDENTITY(1,1) NOT NULL,
	[DepartmentId] [varchar](100) NULL,
	[MetaTitle] [varchar](100) NULL,
	[MetaContent] [varchar](1000) NULL,
	[PageContent] [nvarchar](max) NULL,
	[PageName] [varchar](50) NOT NULL,
	[PageTitle] [nvarchar](100) NULL,
	[PageContentHindi] [nvarchar](max) NULL,
	[PageNameHindi] [varchar](50) NULL,
	[PageTitleHindi] [nvarchar](100) NULL,
	[ContentModifyStatus] [char](1) NULL,
	[Status] [char](1) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_Pages] PRIMARY KEY CLUSTERED 
(
	[PageName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsPagesHistory]    Script Date: 08-05-2021 11:59:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPagesHistory](
	[PageId] [bigint] NOT NULL,
	[DepartmentId] [varchar](100) NULL,
	[MetaTitle] [varchar](100) NULL,
	[MetaContent] [varchar](1000) NULL,
	[PageContent] [nvarchar](max) NULL,
	[PageName] [varchar](50) NOT NULL,
	[PageTitle] [nvarchar](100) NULL,
	[PageContentHindi] [nvarchar](max) NULL,
	[PageNameHindi] [varchar](50) NULL,
	[PageTitleHindi] [nvarchar](100) NULL,
	[ContentModifyStatus] [char](1) NULL,
	[Status] [char](1) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsPagesPublish]    Script Date: 08-05-2021 11:59:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPagesPublish](
	[PageId] [bigint] NOT NULL,
	[DepartmentId] [varchar](100) NULL,
	[MetaTitle] [varchar](100) NULL,
	[MetaContent] [varchar](1000) NULL,
	[PageContent] [nvarchar](max) NULL,
	[PageName] [varchar](50) NULL,
	[PageTitle] [nvarchar](100) NULL,
	[PageContentHindi] [nvarchar](max) NULL,
	[PageNameHindi] [varchar](50) NULL,
	[PageTitleHindi] [nvarchar](100) NULL,
	[ContentModifyStatus] [char](1) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsPublicMenu]    Script Date: 08-05-2021 11:59:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPublicMenu](
	[MenuId] [int] IDENTITY(1,1) NOT NULL,
	[ModuleId] [int] NULL,
	[MenuName] [nvarchar](500) NULL,
	[MenuNameHindi] [nvarchar](500) NULL,
	[ParentId] [int] NULL,
	[PageId] [int] NULL,
	[Path] [varchar](200) NULL,
	[LinkType] [varchar](10) NULL,
	[Target] [varchar](10) NULL,
	[Status] [char](1) NULL,
	[Priority] [int] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsPublicMenu] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsPublicMenu_History]    Script Date: 08-05-2021 11:59:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPublicMenu_History](
	[MenuId] [int] NOT NULL,
	[ModuleId] [int] NULL,
	[MenuName] [nvarchar](500) NULL,
	[MenuNameHindi] [nvarchar](500) NULL,
	[ParentId] [int] NULL,
	[PageId] [int] NULL,
	[Path] [varchar](200) NULL,
	[LinkType] [varchar](10) NULL,
	[Target] [varchar](10) NULL,
	[Status] [char](1) NULL,
	[Priority] [int] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsPublicMenuPublish]    Script Date: 08-05-2021 11:59:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsPublicMenuPublish](
	[MenuId] [bigint] NOT NULL,
	[ModuleId] [int] NULL,
	[MenuName] [nvarchar](500) NULL,
	[MenuNameHindi] [nvarchar](500) NULL,
	[ParentId] [int] NULL,
	[PageId] [int] NULL,
	[Path] [varchar](200) NULL,
	[LinkType] [varchar](10) NULL,
	[Target] [varchar](10) NULL,
	[Priority] [int] NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsRole]    Script Date: 08-05-2021 11:59:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsRole](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleTitle] [nvarchar](100) NULL,
	[Role] [char](1) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_cmsRole] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsSection]    Script Date: 08-05-2021 11:59:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsSection](
	[SectionId] [bigint] IDENTITY(1,1) NOT NULL,
	[PageId] [bigint] NULL,
	[SectionContent] [nvarchar](max) NULL,
	[SectionName] [varchar](50) NOT NULL,
	[SectionTitle] [nvarchar](100) NULL,
	[Status] [char](1) NULL,
	[CreatedOn] [datetime] NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsSection] PRIMARY KEY CLUSTERED 
(
	[SectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsSectionHistory]    Script Date: 08-05-2021 11:59:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsSectionHistory](
	[SectionId] [bigint] NOT NULL,
	[PageId] [bigint] NULL,
	[SectionContent] [nvarchar](max) NULL,
	[SectionName] [varchar](50) NOT NULL,
	[SectionTitle] [nvarchar](100) NULL,
	[Status] [char](1) NULL,
	[CreatedOn] [datetime] NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsSectionPublish]    Script Date: 08-05-2021 11:59:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsSectionPublish](
	[SectionId] [bigint] NOT NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsSMSKit]    Script Date: 08-05-2021 11:59:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsSMSKit](
	[KitId] [int] IDENTITY(1,1) NOT NULL,
	[KitUrl] [nvarchar](500) NULL,
	[KitKey] [varchar](250) NULL,
	[UserName] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsStatus]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Prefix] [char](1) NULL,
	[StatusName] [varchar](50) NULL,
	[CreatedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[CIPAddress] [varchar](50) NULL,
	[UpdatedBy] [varchar](50) NULL,
	[UpdatedDate] [datetime] NULL,
	[UIPAddress] [varchar](50) NULL,
	[StatusFor] [char](3) NULL,
 CONSTRAINT [PK_StatusMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsTenderCategory]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTenderCategory](
	[CategoryId] [bigint] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](100) NULL,
	[Status] [char](1) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsTenderCategory] PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsTenderCategoryHistory]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTenderCategoryHistory](
	[CategoryId] [bigint] NULL,
	[CategoryName] [nvarchar](100) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsTenderCategoryPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTenderCategoryPublish](
	[CategoryId] [bigint] NOT NULL,
	[Status] [char](10) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UpdatedOn] [datetime] NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsTenderCategoryPublish] PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsTenderDocs]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTenderDocs](
	[tenderDocsId] [int] IDENTITY(1,1) NOT NULL,
	[tenderId] [int] NULL,
	[corrigendumTitle] [varchar](200) NULL,
	[corrName] [varchar](100) NULL,
	[format2] [varchar](100) NULL,
	[submissionDate] [varchar](100) NULL,
	[tenderDocument] [varchar](100) NULL,
	[tenderDocument1] [varchar](100) NULL,
	[tenderDocument2] [varchar](100) NULL,
	[tenderDocument3] [varchar](100) NULL,
	[tenderDocument4] [varchar](100) NULL,
	[linkName] [varchar](200) NULL,
	[linkName1] [varchar](200) NULL,
	[linkName2] [varchar](200) NULL,
	[linkName3] [varchar](200) NULL,
	[linkName4] [varchar](200) NULL,
	[createDate] [datetime] NULL,
	[modifyDate] [datetime] NULL,
	[status] [varchar](100) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [TenderDocs_PRIMARY] PRIMARY KEY NONCLUSTERED 
(
	[tenderDocsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsTenderHistroy]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTenderHistroy](
	[tenderId] [bigint] NOT NULL,
	[nameOfOrganization] [varchar](200) NULL,
	[typeOfOrganization] [varchar](100) NULL,
	[tenderTitle] [varchar](200) NULL,
	[tenderRefNo] [varchar](200) NULL,
	[productCategory] [varchar](200) NULL,
	[subCategory] [varchar](200) NULL,
	[tenderValueType] [varchar](100) NULL,
	[tenderValue] [varchar](100) NULL,
	[emd] [varchar](100) NULL,
	[documentCost] [varchar](100) NULL,
	[tenderType] [varchar](100) NULL,
	[biddingType] [varchar](100) NULL,
	[limited] [varchar](100) NULL,
	[location] [varchar](100) NULL,
	[firstAnnouncementDate] [varchar](100) NULL,
	[lastDateOfCollection] [varchar](100) NULL,
	[lastDateForSubmission] [varchar](100) NULL,
	[openingDate] [varchar](100) NULL,
	[workDescription] [nvarchar](max) NULL,
	[preQualification] [nvarchar](max) NULL,
	[preBidMeet] [varchar](100) NULL,
	[tenderDocument] [varchar](100) NULL,
	[tenderDocument1] [varchar](100) NULL,
	[tenderDocument2] [varchar](100) NULL,
	[tenderDocument3] [varchar](100) NULL,
	[tenderDocument4] [varchar](100) NULL,
	[tenderDocument5] [varchar](100) NULL,
	[tenderDocument6] [varchar](100) NULL,
	[tenderDocument7] [varchar](100) NULL,
	[extradoc] [varchar](100) NULL,
	[extradoc1] [varchar](100) NULL,
	[extradoc2] [varchar](100) NULL,
	[tenderDocumentExtra] [varchar](200) NULL,
	[hindiDocs] [varchar](100) NULL,
	[linkName] [varchar](200) NULL,
	[linkName1] [varchar](200) NULL,
	[linkName2] [varchar](200) NULL,
	[linkName3] [varchar](200) NULL,
	[linkName4] [varchar](200) NULL,
	[format1] [varchar](100) NULL,
	[format2] [varchar](100) NULL,
	[format3] [varchar](100) NULL,
	[format4] [varchar](100) NULL,
	[format5] [varchar](100) NULL,
	[createDate] [datetime] NULL,
	[modifyDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[PublishedDate] [datetime] NULL,
	[status] [varchar](100) NULL,
	[UnderEvaluation] [varchar](10) NULL,
	[LastDateOfEvaluation] [datetime] NULL,
	[depName] [varchar](200) NULL,
	[recievingDate] [varchar](100) NULL,
	[assignTo] [varchar](100) NULL,
	[descriptionOfAssign] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UIPAddress] [nvarchar](100) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionName] [nvarchar](20) NULL,
	[ActionOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsTenderPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTenderPublish](
	[tenderId] [bigint] NOT NULL,
	[nameOfOrganization] [varchar](200) NULL,
	[typeOfOrganization] [varchar](100) NULL,
	[tenderTitle] [varchar](200) NULL,
	[tenderRefNo] [varchar](200) NULL,
	[productCategory] [varchar](200) NULL,
	[subCategory] [varchar](200) NULL,
	[tenderValueType] [varchar](100) NULL,
	[tenderValue] [varchar](100) NULL,
	[emd] [varchar](100) NULL,
	[documentCost] [varchar](100) NULL,
	[tenderType] [varchar](100) NULL,
	[biddingType] [varchar](100) NULL,
	[limited] [varchar](100) NULL,
	[location] [varchar](100) NULL,
	[firstAnnouncementDate] [varchar](100) NULL,
	[lastDateOfCollection] [varchar](100) NULL,
	[lastDateForSubmission] [varchar](100) NULL,
	[openingDate] [varchar](100) NULL,
	[workDescription] [nvarchar](max) NULL,
	[preQualification] [nvarchar](max) NULL,
	[preBidMeet] [varchar](100) NULL,
	[tenderDocument] [varchar](100) NULL,
	[tenderDocument1] [varchar](100) NULL,
	[tenderDocument2] [varchar](100) NULL,
	[tenderDocument3] [varchar](100) NULL,
	[tenderDocument4] [varchar](100) NULL,
	[tenderDocument5] [varchar](100) NULL,
	[tenderDocument6] [varchar](100) NULL,
	[tenderDocument7] [varchar](100) NULL,
	[extradoc] [varchar](100) NULL,
	[extradoc1] [varchar](100) NULL,
	[extradoc2] [varchar](100) NULL,
	[tenderDocumentExtra] [varchar](200) NULL,
	[hindiDocs] [varchar](100) NULL,
	[linkName] [varchar](200) NULL,
	[linkName1] [varchar](200) NULL,
	[linkName2] [varchar](200) NULL,
	[linkName3] [varchar](200) NULL,
	[linkName4] [varchar](200) NULL,
	[format1] [varchar](100) NULL,
	[format2] [varchar](100) NULL,
	[format3] [varchar](100) NULL,
	[format4] [varchar](100) NULL,
	[format5] [varchar](100) NULL,
	[createDate] [datetime] NULL,
	[modifyDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[PublishedDate] [datetime] NULL,
	[status] [varchar](100) NULL,
	[UnderEvaluation] [varchar](10) NULL,
	[LastDateOfEvaluation] [datetime] NULL,
	[depName] [varchar](200) NULL,
	[recievingDate] [varchar](100) NULL,
	[assignTo] [varchar](100) NULL,
	[descriptionOfAssign] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsTenderPublish] PRIMARY KEY CLUSTERED 
(
	[tenderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cmsTenders]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cmsTenders](
	[tenderId] [bigint] IDENTITY(1,1) NOT NULL,
	[nameOfOrganization] [varchar](200) NULL,
	[typeOfOrganization] [varchar](100) NULL,
	[tenderTitle] [varchar](200) NULL,
	[tenderRefNo] [varchar](200) NULL,
	[productCategory] [varchar](200) NULL,
	[subCategory] [varchar](200) NULL,
	[tenderValueType] [varchar](100) NULL,
	[tenderValue] [varchar](100) NULL,
	[emd] [varchar](100) NULL,
	[documentCost] [varchar](100) NULL,
	[tenderType] [varchar](100) NULL,
	[biddingType] [varchar](100) NULL,
	[limited] [varchar](100) NULL,
	[location] [varchar](100) NULL,
	[firstAnnouncementDate] [varchar](100) NULL,
	[lastDateOfCollection] [varchar](100) NULL,
	[lastDateForSubmission] [varchar](100) NULL,
	[openingDate] [varchar](100) NULL,
	[workDescription] [nvarchar](max) NULL,
	[preQualification] [nvarchar](max) NULL,
	[preBidMeet] [varchar](100) NULL,
	[tenderDocument] [varchar](100) NULL,
	[tenderDocument1] [varchar](100) NULL,
	[tenderDocument2] [varchar](100) NULL,
	[tenderDocument3] [varchar](100) NULL,
	[tenderDocument4] [varchar](100) NULL,
	[tenderDocument5] [varchar](100) NULL,
	[tenderDocument6] [varchar](100) NULL,
	[tenderDocument7] [varchar](100) NULL,
	[extradoc] [varchar](100) NULL,
	[extradoc1] [varchar](100) NULL,
	[extradoc2] [varchar](100) NULL,
	[tenderDocumentExtra] [varchar](200) NULL,
	[hindiDocs] [varchar](100) NULL,
	[linkName] [varchar](200) NULL,
	[linkName1] [varchar](200) NULL,
	[linkName2] [varchar](200) NULL,
	[linkName3] [varchar](200) NULL,
	[linkName4] [varchar](200) NULL,
	[format1] [varchar](100) NULL,
	[format2] [varchar](100) NULL,
	[format3] [varchar](100) NULL,
	[format4] [varchar](100) NULL,
	[format5] [varchar](100) NULL,
	[createDate] [datetime] NULL,
	[modifyDate] [datetime] NULL,
	[status] [varchar](100) NULL,
	[depName] [varchar](200) NULL,
	[recievingDate] [varchar](100) NULL,
	[assignTo] [varchar](100) NULL,
	[descriptionOfAssign] [nvarchar](max) NULL,
	[UnderEvaluation] [varchar](10) NULL,
	[LastDateOfEvaluation] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[PublishedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](100) NULL,
	[CIPAddress] [nvarchar](100) NULL,
	[UpdatedBy] [nvarchar](100) NULL,
	[UIPAddress] [nvarchar](100) NULL,
 CONSTRAINT [PK_cmsTenders] PRIMARY KEY CLUSTERED 
(
	[tenderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApplicationUser] ADD  CONSTRAINT [DF_LoginDetails_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[ApplicationUser] ADD  CONSTRAINT [DF_LoginDetails_LastUpdatedOn]  DEFAULT (getdate()) FOR [LastUpdatedOn]
GO
ALTER TABLE [dbo].[cmsMainSite] ADD  CONSTRAINT [DF_cmsMainSite_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsMainSite_History] ADD  CONSTRAINT [DF_cmsMainSite_History_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsMainSitePublish] ADD  CONSTRAINT [DF_cmsMainSitePublish_CreatedOn_1]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsNotificationPublish] ADD  CONSTRAINT [DF_cmsNotificationPublish_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsPagesHistory] ADD  CONSTRAINT [DF_cmsPagesHistory_CreatedOn1]  DEFAULT (getdate()) FOR [CreatedBy]
GO
ALTER TABLE [dbo].[cmsPagesPublish] ADD  CONSTRAINT [DF_cmsPublicPages_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsPublicMenu] ADD  CONSTRAINT [DF_cmsPublicMenu_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsPublicMenu_History] ADD  CONSTRAINT [DF_PublicMenu_History_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsPublicMenuPublish] ADD  CONSTRAINT [DF_cmsPublicMenuPublish_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsSectionPublish] ADD  CONSTRAINT [DF_cmsSectionPublish_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsTenderCategory] ADD  CONSTRAINT [DF__cmsTender__Creat__4D94879B]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[cmsTenderCategoryPublish] ADD  CONSTRAINT [DF_cmsTenderCategoryPublish_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
/****** Object:  StoredProcedure [dbo].[App_CreateExceptionLog]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[App_CreateExceptionLog]      
(      
@ExceptionMsg nvarchar(max)=null,  
@ControllerName nvarchar(100) =null,      
@ActionName nvarchar(100) =null,  
@Other nvarchar(max)=null,      
@CreatedBy nvarchar(50)      
)      
as      
begin      
insert into appExceptionLog(ExceptionMsg,ControllerName,ActionName,Other,CreatedOn,CreatedBy)      
values (@ExceptionMsg,@ControllerName,@ActionName,@Other,GETDATE(),@CreatedBy)      
end    
GO
/****** Object:  StoredProcedure [dbo].[App_GetLoginDetailByUserId]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
              
CREATE proc [dbo].[App_GetLoginDetailByUserId] -- [App_GetLoginDetailByUserId] 'Superadmin'                                       
                                      
(@Userid varchar(50))                                              
as                                              
begin            
declare @Menulist nvarchar(max)           
declare @Menulist2 nvarchar(max)           
          
Select @Menulist=ISNULL((  
  Select  
  case when (select COUNT(*) from cmsApplicationDetails s where s.ParentId=d.MenuId)>0 then    
  (  
 d.PageName+ ISNULL((Select  ISNULL(dd.PageName,'') from ApplicationUser as ll     
  inner join cmsApplicationRights rr on ll.Role=convert(varchar(10), rr.Role)         
  inner join cmsApplicationDetails dd on  rr.MenuId=dd.MenuId          
where ll.userid=@Userid and dd.ParentId=d.MenuId   and rr.Status=1 and dd.Status='A'     order by  Priority asc,dd.ParentId, dd.MenuId    
for XML path('')),'')+'</ul>'  
  
)  
    
  else  d.PageName end  
    
  from ApplicationUser as l     
  inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)         
  inner join cmsApplicationDetails d on  r.MenuId=d.MenuId          
where userid=@Userid   and r.Status=1   and d.ParentId is null and d.Status='A'    order by  Priority asc,d.ParentId, d.MenuId                
for XML path('')),'')    
    
    
select a.Id,UserId,Password,isnull(a.RoleId,'') as RoleId,              
isnull(EmployeeId,'') as EmployeeId,              
isnull(MobileNo,'') as MobileNo,            
isnull(UserName,'') as UserName,              
isnull(Email,'') as Email,              
isnull(OfficeType,'') as OfficeType,              
isnull(OfficeId,'') as OfficeId,      
isnull(DepartmentId,'') as DepartmentIds,      
isnull(r.RoleTitle,'') as RoleName,                                     
case when LastLoginDateTime is null then convert(varchar(10),isnull(GETDATE(),''),103)+' '+convert(varchar(8),                
convert(time,GETDATE()))  else  convert(varchar(10),isnull(LastLoginDateTime,''),103)+' '+convert(varchar(8),                
convert(time,LastLoginDateTime))   end as LastLoginDateTime,isnull(LastLoginIPAddress,'')  as LastLoginIPAddress,                                    
isnull(CurrentIPAddress,'') as CurrentIPAddress,              
case when CurrentLoginDateTime is null then '' else convert(varchar(10),isnull(CurrentLoginDateTime,''),103)+' '+convert(varchar(8),                
convert(time,CurrentLoginDateTime)) end as CurrentLoginDateTime,              
                          
a.Role,@Menulist MenuDetail          
from [dbo].[ApplicationUser] a           
        
inner join cmsRole as r on a.RoleId=r.RoleId                                                             
WHERE a.UserId = @Userid                                              
end   
GO
/****** Object:  StoredProcedure [dbo].[App_UpdateLoginInfo]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE proc [dbo].[App_UpdateLoginInfo]              
(              
@UserId varchar(50),              
@IpAddress varchar(50)  ,  
@LogType           varchar(50)    
)              
as              
begin     
if lower(@LogType) ='login'    
begin         
insert into ApplicationUserLog              
values ( @UserId,'Login',getdate(),@UserId,@IpAddress)    
update ApplicationUser set LastLoginDateTime =CurrentLoginDateTime,LastLoginIPAddress=CurrentIPAddress,              
CurrentIPAddress=@IpAddress , CurrentLoginDateTime=GETDATE() where UserId=@UserId           
select  Role from ApplicationUser  where   userid=@UserId        
end  
else    
begin         
insert into ApplicationUserLog              
values ( @UserId,@LogType,getdate(),@UserId,@IpAddress)    
update ApplicationUser set LastLoginDateTime =CurrentLoginDateTime,LastLoginIPAddress=CurrentIPAddress,              
CurrentIPAddress=@IpAddress , CurrentLoginDateTime=GETDATE() where UserId=@UserId           
end  
end   
GO
/****** Object:  StoredProcedure [dbo].[DeleteApplicationUser]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 Create Procedure [dbo].[DeleteApplicationUser]    
@Id int,    
@CreatedBy nvarchar(100),    
@CIPAddress nvarchar(100)    
As    
begin    
Begin Tran    
begin try    
if exists(Select * from ApplicationUser where Id=@Id)    
begin    
Delete from ApplicationUser where Id=@Id    
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage    
end    
else    
begin    
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage    
end    
commit    
end try    
begin catch    
Select 'f' ResultStatus, 'Exception Error' ResultMessage    
end catch    
    
end    
    
    
GO
/****** Object:  StoredProcedure [dbo].[DeleteCareer]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 Create Procedure [dbo].[DeleteCareer]        
@CareerId int,        
@CreatedBy nvarchar(100),        
@CIPAddress nvarchar(100)        
As        
begin        
Begin Tran        
begin try        
if exists(Select * from cmsCareer where CareerId=@CareerId)        
begin        
Delete from cmsCareer where CareerId=@CareerId        
Delete from cmsCareerPublish where CareerId=@CareerId       
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage        
end        
else        
begin        
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage        
end        
commit        
end try        
begin catch        
Select 'f' ResultStatus, 'Exception Error' ResultMessage        
end catch        
        
end        
GO
/****** Object:  StoredProcedure [dbo].[DeleteClone]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE Procedure [dbo].[DeleteClone]      
@CloneId int,      
@CreatedBy nvarchar(100),      
@CIPAddress nvarchar(100)      
As      
begin      
Begin Tran      
begin try      
if exists(Select * from cmsClone where CloneId=@CloneId)      
begin      
Delete from cmsClone where CloneId=@CloneId      
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage      
end      
else      
begin      
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage      
end      
commit      
end try      
begin catch      
Select 'f' ResultStatus, 'Exception Error' ResultMessage      
end catch      
      
end      
      
      
GO
/****** Object:  StoredProcedure [dbo].[DeleteDepartment]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
 Create Procedure [dbo].[DeleteDepartment]            
@DepartmentId int,            
@CreatedBy nvarchar(100),            
@CIPAddress nvarchar(100)            
As            
begin            
Begin Tran            
begin try            
if exists(Select * from cmsDepartment where DepartmentId=@DepartmentId)            
begin            
Delete from cmsDepartment where DepartmentId=@DepartmentId            
--Delete from cmsDepartmentPublish where DepartmentId=@DepartmentId           
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage            
end            
else            
begin            
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage            
end            
commit            
end try            
begin catch            
Select 'f' ResultStatus, 'Exception Error' ResultMessage            
end catch            
            
end 
GO
/****** Object:  StoredProcedure [dbo].[DeleteFaq]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 Create Procedure [dbo].[DeleteFaq]        
@FaqId int,        
@CreatedBy nvarchar(100),        
@CIPAddress nvarchar(100)        
As        
begin        
Begin Tran        
begin try        
if exists(Select * from cmsFaq where FaqId=@FaqId)        
begin        
Delete from cmsFaq where FaqId=@FaqId        
Delete from cmsFaqPublish where FaqId=@FaqId       
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage        
end        
else        
begin        
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage        
end        
commit        
end try        
begin catch        
Select 'f' ResultStatus, 'Exception Error' ResultMessage        
end catch        
        
end        
GO
/****** Object:  StoredProcedure [dbo].[DeleteGetComaplainOrFeedback]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 Create Procedure [dbo].[DeleteGetComaplainOrFeedback]        
@ComplainId int,        
@CreatedBy nvarchar(100),        
@CIPAddress nvarchar(100)        
As        
begin        
Begin Tran        
begin try        
if exists(Select * from cmsCompainOrFeedback where ComplainId=@ComplainId)        
begin        
Delete from cmsCompainOrFeedback where ComplainId=@ComplainId        
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage        
end        
else        
begin        
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage        
end        
commit        
end try        
begin catch        
Select 'f' ResultStatus, 'Exception Error' ResultMessage        
end catch        
        
end        
GO
/****** Object:  StoredProcedure [dbo].[DeleteMaiSite]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE Procedure [dbo].[DeleteMaiSite]          
@MainSiteId int,          
@CreatedBy nvarchar(100),          
@CIPAddress nvarchar(100)          
As          
begin          
Begin Tran          
begin try          
if exists(Select * from cmsMainSite where MainSiteId=@MainSiteId)          
begin          
Delete from cmsMainSite where MainSiteId=@MainSiteId          
Delete from cmsMainSitePublish where MainSiteId=@MainSiteId                 
  
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage          
end          
else          
begin          
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage          
end          
commit          
end try          
begin catch          
Select 'f' ResultStatus, 'Exception Error' ResultMessage          
end catch          
          
end          
          
GO
/****** Object:  StoredProcedure [dbo].[DeleteMediaGallery]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 Create Procedure [dbo].[DeleteMediaGallery]      
@MediaId int,      
@CreatedBy nvarchar(100),      
@CIPAddress nvarchar(100)      
As      
begin      
Begin Tran      
begin try      
if exists(Select * from cmsMediaGallery where MediaId=@MediaId)      
begin      
Delete from cmsMediaGallery where MediaId=@MediaId      
Delete from cmsMediaGalleryPublish where MediaId=@MediaId     
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage      
end      
else      
begin      
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage      
end      
commit      
end try      
begin catch      
Select 'f' ResultStatus, 'Exception Error' ResultMessage      
end catch      
      
end      
      
GO
/****** Object:  StoredProcedure [dbo].[DeleteNotification]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
 Create Procedure [dbo].[DeleteNotification]          
@NotificationId int,          
@CreatedBy nvarchar(100),          
@CIPAddress nvarchar(100)          
As          
begin          
Begin Tran          
begin try          
if exists(Select * from cmsNotification where NotificationId=@NotificationId)          
begin          
Delete from cmsNotification where NotificationId=@NotificationId          
Delete from cmsNotificationPublish where NotificationId=@NotificationId         
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage          
end          
else          
begin          
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage          
end          
commit          
end try          
begin catch          
Select 'f' ResultStatus, 'Exception Error' ResultMessage          
end catch          
          
end 
GO
/****** Object:  StoredProcedure [dbo].[DeletePages]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE Procedure [dbo].[DeletePages]    
@PageId int,    
@CreatedBy nvarchar(100),    
@CIPAddress nvarchar(100)    
As    
begin    
Begin Tran    
begin try    
if exists(Select * from cmsPages where PageId=@PageId)    
begin    
Delete from cmsPages where PageId=@PageId    
Delete from cmsPagesPublish where PageId=@PageId    
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage    
end    
else    
begin    
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage    
end    
commit    
end try    
begin catch    
Select 'f' ResultStatus, 'Exception Error' ResultMessage    
end catch    
    
end    
    
    
GO
/****** Object:  StoredProcedure [dbo].[DeletePublicMenu]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE Procedure [dbo].[DeletePublicMenu]  
@MenuId int,  
@CreatedBy nvarchar(100),  
@CIPAddress nvarchar(100)  
As  
begin  
Begin Tran  
begin try  
if exists(Select * from cmsPublicMenu where MenuId=@MenuId)  
begin  
Delete from cmsPublicMenu where MenuId=@MenuId  
Delete from cmsPublicMenuPublish where MenuId=@MenuId  
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage  
end  
else  
begin  
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage  
end  
commit  
end try  
begin catch  
Select 'f' ResultStatus, 'Exception Error' ResultMessage  
end catch  
  
end  
  
  
  
GO
/****** Object:  StoredProcedure [dbo].[DeleteSection]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE Procedure [dbo].[DeleteSection]      
@SectionId int,      
@CreatedBy nvarchar(100),      
@CIPAddress nvarchar(100)      
As      
begin      
Begin Tran      
begin try      
if exists(Select * from cmsSection where SectionId=@SectionId)      
begin      
Delete from cmsSection where SectionId=@SectionId      
Delete from cmsSectionPublish where SectionId=@SectionId      
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage      
end      
else      
begin      
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage      
end      
commit      
end try      
begin catch      
Select 'f' ResultStatus, 'Exception Error' ResultMessage      
end catch      
      
end      
      
GO
/****** Object:  StoredProcedure [dbo].[DeleteTender]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE Procedure [dbo].[DeleteTender]        
@TenderId int,        
@CreatedBy nvarchar(100),        
@CIPAddress nvarchar(100)        
As        
begin        
Begin Tran        
begin try        
if exists(Select * from cmsTenders where TenderId=@TenderId)        
begin        
Delete from cmsTenders where TenderId=@TenderId        
Delete from cmsTenderPublish where TenderId=@TenderId        
Delete from cmsTenderDocs where TenderId=@TenderId        

Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage        
end        
else        
begin        
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage        
end        
commit        
end try        
begin catch        
Select 'f' ResultStatus, 'Exception Error' ResultMessage        
end catch        
        
end        
        
GO
/****** Object:  StoredProcedure [dbo].[DeleteTenderCategory]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE Procedure [dbo].[DeleteTenderCategory]
@CategoryId int,
@CreatedBy nvarchar(100),
@CIPAddress nvarchar(100)
As
begin
Begin Tran
begin try
if exists(Select * from cmsTenderCategory where CategoryId=@CategoryId)
begin
Delete from cmsTenderCategory where CategoryId=@CategoryId
Delete from cmsTenderCategoryPublish where CategoryId=@CategoryId
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage
end
else
begin
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage
end
commit
end try
begin catch
Select 'f' ResultStatus, 'Exception Error' ResultMessage
end catch

end



GO
/****** Object:  StoredProcedure [dbo].[DeleteTenderDocs]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 Create Procedure [dbo].[DeleteTenderDocs]    
@tenderDocsId int,    
@CreatedBy nvarchar(100),    
@CIPAddress nvarchar(100)    
As    
begin    
Begin Tran    
begin try    
if exists(Select * from cmsTenderDocs where tenderDocsId=@tenderDocsId)    
begin    
Delete from cmsTenderDocs where tenderDocsId=@tenderDocsId    
Select 't' ResultStatus, 'Data Deleted Successfully.' ResultMessage    
end    
else    
begin    
Select 'f' ResultStatus, 'Data delete failed because data not found.' ResultMessage    
end    
commit    
end try    
begin catch    
Select 'f' ResultStatus, 'Exception Error' ResultMessage    
end catch    
    
end    
    
    
    
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetDepartmentID]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[DropDownGetDepartmentID]  -- DropDownGetDepartmentID 1
@DepartmentId varchar(250)
as  
Select DepartmentId as Id, DepartmentName as Value ,DepartmentName as Text from cmsDepartment

where DepartmentId in(select value from dbo.fn_Split(@DepartmentId,','))
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetDepartmentWithoutID]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
    
Create procedure [dbo].[DropDownGetDepartmentWithoutID]  -- DropDownGetDepartmentWithoutID 1  
@DepartmentId varchar(250)=null  
as    
Select DepartmentId as Id, DepartmentName as Value ,DepartmentName as Text from cmsDepartment  
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetMediaGalleryType]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[DropDownGetMediaGalleryType]
as
Select Id as Id, MediaType as Value ,MediaType as Text from cmsMediaGalleryType
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetPageList]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[DropDownGetPageList]
as
Select PageName as Id, PageName as Value ,PageName as Text from cmsPages
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetPageListID]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[DropDownGetPageListID]  
as  
Select PageId as Id, PageName as Value ,PageName as Text from cmsPages
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetPublicMenuList]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[DropDownGetPublicMenuList]  
as  
Select MenuName as Id, MenuName as Value ,MenuName as Text from cmsPublicMenu
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetPublicMenuListID]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
CREATE procedure [dbo].[DropDownGetPublicMenuListID]      
@ParentId int =null  
as      

declare @ParentIds VARCHAR(MAX)=(
 SELECT ',' + convert(varchar, MenuId) FROM cmsPublicMenu                                                                                                                    
     WHERE     ParentId is null FOR XML PATH (''))

select 
MenuId as Id, MenuName as Value ,MenuName as Text   
from cmsPublicMenu where ParentId is null 

union all
 select 
MenuId as Id, MenuName as Value ,'-- '+MenuName as Text   from cmsPublicMenu  where ParentId  in 
(select value from fn_Split(@ParentIds,','))
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetRoleList]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE procedure [dbo].[DropDownGetRoleList]    -- DropDownGetRoleList 'Admin'
@UserId varchar(100)=null    
as        
if(@UserId='Admin')
begin
Select Role as Id, RoleTitle as Value ,RoleTitle as Text from cmsRole  
where RoleTitle!='Superadmin'
end
else if(@UserId='Superadmin')
begin
Select Role as Id, RoleTitle as Value ,RoleTitle as Text from cmsRole  
end
else
begin
Select Role as Id, RoleTitle as Value ,RoleTitle as Text from cmsRole  
where RoleTitle!='Superadmin' and RoleTitle!='Admin'
end
GO
/****** Object:  StoredProcedure [dbo].[DropDownGetRoleListID]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE procedure [dbo].[DropDownGetRoleListID]    
as    
Select RoleId as Id, RoleTitle as Value ,RoleTitle as Text from cmsRole
GO
/****** Object:  StoredProcedure [dbo].[GeCareerCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [dbo].[GeCareerCreateButton]  -- GeManagePagesCreateButton 'Admin','PagesManage'  
@UserId varchar(50)=null,  
@ActionName varchar(50)=null  
As
Select (case when (Select r.AllowInsert from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName='PagesManage')=1 then 

('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Career">Add New Vacancy</a></div>') else '' end) as DeletePermission  
  
GO
/****** Object:  StoredProcedure [dbo].[GeDepartmentCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
    
Create Procedure [dbo].[GeDepartmentCreateButton]  -- GeDepartmentCreateButton 'Admin','GetDepartment'      
@UserId varchar(50)=null,      
@ActionName varchar(50)=null      
As    
Select (case when (Select r.AllowInsert from ApplicationUser as l       
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)        
inner join cmsApplicationDetails d on r.MenuId=d.MenuId       
where userid=@UserId and r.Status=1   and ActionName='GetDepartment')=1 then     
    
('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Department">Add New Department</a></div>') else '' end) as DeletePermission 
GO
/****** Object:  StoredProcedure [dbo].[GeFaqCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
CREATE Procedure [dbo].[GeFaqCreateButton]  -- UsersManage 'Admin','SectionManage'      
@UserId varchar(50)=null,      
@ActionName varchar(50)=null      
As    
Select (case when (Select r.AllowInsert from ApplicationUser as l       
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)        
inner join cmsApplicationDetails d on r.MenuId=d.MenuId       
where userid=@UserId and r.Status=1   and ActionName='FAQManage')=1 then     
    
('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Faq">Add New FAQ</a></div>') else '' end) as DeletePermission 
GO
/****** Object:  StoredProcedure [dbo].[GeManagePagesCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE Procedure [dbo].[GeManagePagesCreateButton]  -- GeManagePagesCreateButton 'Admin','PagesManage'    
@UserId varchar(50)=null,    
@ActionName varchar(50)=null    
As  


Select 
(Select count(*) from cmsPages) AllPages,
(Select count(*) from cmsPages where ContentModifyStatus='P') AllPublish,
(Select count(*) from cmsPages Where ContentModifyStatus='D') PendingForPublish,

 (case when (Select r.AllowInsert from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName='PagesManage')=1 then   
  
('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Pages">Add New Page</a></div>') else '' end) as InsertPermission    
    
GO
/****** Object:  StoredProcedure [dbo].[GeMediaGalleryCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
Create Procedure [dbo].[GeMediaGalleryCreateButton]  -- UsersManage 'Admin','SectionManage'    
@UserId varchar(50)=null,    
@ActionName varchar(50)=null    
As  
Select (case when (Select r.AllowInsert from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName='GetMediaGallery')=1 then   
  
('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/MediaGallery">Add New Media</a></div>') else '' end) as DeletePermission    
GO
/****** Object:  StoredProcedure [dbo].[GeNotificationCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
Create Procedure [dbo].[GeNotificationCreateButton]  -- GeNotificationCreateButton 'Admin','SectionManage'    
@UserId varchar(50)=null,    
@ActionName varchar(50)=null    
As  
Select (case when (Select r.AllowInsert from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName='GetNotification')=1 then   
  
('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Notification">Add New Notification</a></div>') else '' end) as DeletePermission    
GO
/****** Object:  StoredProcedure [dbo].[GeSectionManageCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [dbo].[GeSectionManageCreateButton]  -- GeSectionManageCreateButton 'Admin','SectionManage'  
@UserId varchar(50)=null,  
@ActionName varchar(50)=null  
As
Select (case when (Select r.AllowInsert from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName='SectionManage')=1 then 

('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Section">Add New Section</a></div>') else '' end) as DeletePermission  
  
GO
/****** Object:  StoredProcedure [dbo].[GetApplicationDetails]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetApplicationDetails]
@MenuId	varchar(10)=Null
as
      Select MenuId
      ,ModuleId
      ,MenuName
      ,ParentId
      ,PageName
      ,Status
      ,Priority
  FROM cmsApplicationDetails 

GO
/****** Object:  StoredProcedure [dbo].[GetApplicationRoleDetails]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
        
CREATE proc [dbo].[GetApplicationRoleDetails]  --GetApplicationRoleDetails 'Admin'            
@Role varchar(10)         
as               
begin              
select d.MenuName,d.MenuId,r.MenuId as RightMenuId,d.PageName,isnull(r.Status,'N') as rightstatus,      
      
case when r.Status is null then 0 else r.Status end Status,      
case when r.AllowInsert is null then 0 else r.AllowInsert end AllowInsert,      
case when r.AllowDelete is null then 0 else r.AllowDelete end AllowDelete,      
case when r.AllowUpdate is null then 0 else r.AllowUpdate end AllowUpdate,      
case when r.AllowPublish is null then 0 else r.AllowPublish end AllowPublish,      
  
case when d.AllowInsert is null then 0 else d.AllowInsert end AllowInsertCheck,      
case when d.AllowDelete is null then 0 else d.AllowDelete end AllowDeleteCheck,      
case when d.AllowUpdate is null then 0 else d.AllowUpdate end AllowUpdateCheck,      
case when d.AllowPublish is null then 0 else d.AllowPublish end AllowPublishCheck,      
      
@Role as Role       
from               
(select * from cmsApplicationRights where 
Role=@Role 
--((Role=@Role and @Role is not null) or @Role is null)        

) as  r              
right join              
(select * from cmsApplicationDetails Where Status='A') as d on r.MenuId=d.MenuId order by d.Priority,d.ParentId asc           
      
      
      
         
end
GO
/****** Object:  StoredProcedure [dbo].[GetCareer]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                  
                  
CREATE procedure [dbo].[GetCareer] -- GetCareer 638,'Admin','GetCareer'                  
@CareerId varchar(50)  =null   ,                  
@UserId varchar(50)=null,                    
@ActionName varchar(50)=null                        
As                  
Select CareerId,                  
     
 (case when (Select r.AllowDelete from ApplicationUser as l                     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                     
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),CareerId) + ')>Delete</a>') else '' end) as DeletePermission,                    
                    
(case when (Select r.AllowUpdate from ApplicationUser as l                     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                     
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Career?CareerId=' + Convert(varchar(10),CareerId) + ' >Edit</a>') else '' end) as EditPermission,                    
                    
(case when (Select r.AllowPublish from ApplicationUser as l                     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                     
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.Status = 'P' then 'success' else 'warning' end) + '" onclick=Publish(' +  Convert(varchar(10),CareerId) + ',"' +p.Status + '")>' + s.StatusName +
  
    
'</a>') else '' end) as PublishPermission,                  
     
 --FORMAT(firstAnnouncementDate,'dd-MMM-yyyy') firstAnnouncementDate,        
-- FORMAT(lastDateForSubmission,'dd-MMM-yyyy') lastDateForSubmission,        
 -- FORMAT(createDate,'dd-MMM-yyyy') createDate  
   
  createDate,    
  FORMAT(CONVERT(date, firstAnnouncementDate,103),'dd-MM-yyyy') firstAnnouncementDate,
  FORMAT(CONVERT(date, lastDateOfCollection,103),'dd-MM-yyyy')  lastDateOfCollection ,
  FORMAT(CONVERT(date, lastDateOfCollection,103),'dd-MM-yyyy')  lastDateForSubmission ,

         lastDateOfCollection lastDateOfCollectionAll,
      nameOfOrganization    
      ,typeOfOrganization    
      ,vacancyTitle    
      ,vacancyRefNo    
      ,productCategory    
      ,subCategory    
      ,vacancyValueType    
      ,vacancyValue    
      ,emd    
      ,documentCost    
      ,vacancyType    
      ,biddingType    
      ,limited    
      ,location    
      ,openingDate    
      ,workDescription    
      ,preQualification    
      ,preBidMeet    
      ,vacancyDocument  vacancyFileName  
      ,vacancyDocument1    
      ,vacancyDocument2    
      ,vacancyDocument3    
      ,vacancyDocument4    
      ,vacancyDocument5    
      ,vacancyDocument6    
      ,vacancyDocument7    
      ,extradoc    
      ,extradoc1    
      ,extradoc2    
      ,vacancyDocumentExtra    
      ,hindiDocs    
      ,linkName    
      ,linkName1    
      ,linkName2    
      ,linkName3    
      ,linkName4    
      ,format1    
      ,format2    
      ,format3    
      ,format4    
      ,format5    
      ,createDate    
      ,modifyDate    
      ,status    
      ,depName    
      ,recievingDate    
      ,assignTo    
      ,descriptionOfAssign    
      ,p.CreatedBy    
      ,p.CIPAddress    
      ,p.UpdatedBy    
      ,p.UIPAddress          
from cmsCareer p                   
left join cmsStatus s on p.Status=s.Prefix                      
                  
Where       
--convert(date,firstAnnouncementDate,103) <= convert(date,GETDATE(),103)       
--and       
--convert(date,lastDateOfCollection,103) >= convert(date,GETDATE(),103)  and      
((CareerId=@CareerId and @CareerId is not null) or @CareerId is null) 

order by CareerId desc
--,  CONVERT(date, lastDateOfCollection,103) desc
GO
/****** Object:  StoredProcedure [dbo].[GetCareerForPublic]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                    
                    
CREATE procedure [dbo].[GetCareerForPublic] -- GetCareerForPublic null,'Admin','GetCareer'                    
@CareerId varchar(50)  =null   ,                    
@DepartmentId varchar(50)  =null                                         
As                    
Select CareerId,createDate,firstAnnouncementDate,lastDateForSubmission nameOfOrganization ,typeOfOrganization    ,vacancyTitle ,vacancyRefNo,productCategory ,subCategory      
      ,vacancyValueType ,vacancyValue,emd,documentCost,vacancyType ,biddingType      
      ,limited ,location ,firstAnnouncementDate,lastDateOfCollection,lastDateForSubmission ,openingDate ,workDescription      
      ,preQualification ,preBidMeet,vacancyDocument  vacancyFileName  ,vacancyDocument1,vacancyDocument2,vacancyDocument3,vacancyDocument4      
      ,vacancyDocument5 ,vacancyDocument6 ,vacancyDocument7,extradoc,extradoc1,extradoc2,vacancyDocumentExtra      
      ,hindiDocs,linkName,linkName1,linkName2,linkName3,linkName4,format1,format2,format3,format4,format5      
      ,createDate,modifyDate ,status,depName,recievingDate,assignTo,descriptionOfAssign ,p.CreatedBy      
      ,p.CIPAddress ,p.UpdatedBy ,p.UIPAddress   ,
	  (case when vacancyDocument is not null then 
	  '<a target="_blank" href="/Upload/Career/'+convert(varchar, CareerId)+'/'+vacancyDocument+'">View Document</a>' 
	  else
	  'No Document'
	  end)
	   
	   ViewDocuemnt
	  
	           
from cmsCareer p                     
left join cmsStatus s on p.Status=s.Prefix                        
                    
Where         
convert(date,firstAnnouncementDate,103) <= convert(date,GETDATE(),103)         
and         
convert(date,lastDateOfCollection,103) >= convert(date,GETDATE(),103)    
and ((CareerId=@CareerId and @CareerId is not null) or @CareerId is null)   
  
and ((depName=@DepartmentId and @DepartmentId is not null) or @DepartmentId is null)   
order by CONVERT(date, lastDateOfCollection,103) desc  
  
  
  
--Convert ERRRR  
--update cmsCareer set lastDateOfCollection=null where lastDateOfCollection in ('-- 00:00','--2011 00:00')  
--update cmsCareer set firstAnnouncementDate=null where firstAnnouncementDate in ('select-selectMonth-selectYear','select-08-2011')  
  
--select  CONVERT(date,lastDateOfCollection,103)   
--from cmsCareer  where lastDateOfCollection not in ('-- 00:00','--2011 00:00')  
--select CONVERT(date,firstAnnouncementDate,103)   
--from cmsCareer  where firstAnnouncementDate not in ('select-selectMonth-selectYear','select-08-2011')
GO
/****** Object:  StoredProcedure [dbo].[GetCareerForPublicAchievVancancy]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                    
                    
CREATE procedure [dbo].[GetCareerForPublicAchievVancancy] -- GetCareerForPublicAchievVancancy null,3                   
@CareerId varchar(50)  =null   ,                    
@DepartmentId varchar(50)  =null                                         
As                    
Select CareerId,createDate,firstAnnouncementDate,lastDateForSubmission nameOfOrganization ,typeOfOrganization    ,vacancyTitle ,vacancyRefNo,productCategory ,subCategory      
      ,vacancyValueType ,vacancyValue,emd,documentCost,vacancyType ,biddingType      
      ,limited ,location ,firstAnnouncementDate,lastDateOfCollection,lastDateForSubmission ,openingDate ,workDescription      
      ,preQualification ,preBidMeet,vacancyDocument  vacancyFileName  ,vacancyDocument1,vacancyDocument2,vacancyDocument3,vacancyDocument4      
      ,vacancyDocument5 ,vacancyDocument6 ,vacancyDocument7,extradoc,extradoc1,extradoc2,vacancyDocumentExtra      
      ,hindiDocs,linkName,linkName1,linkName2,linkName3,linkName4,format1,format2,format3,format4,format5      
      ,createDate,modifyDate ,status,depName,recievingDate,assignTo,descriptionOfAssign ,p.CreatedBy      
      ,p.CIPAddress ,p.UpdatedBy ,p.UIPAddress   ,
	  (case when vacancyDocument is not null then 
	  '<a target="_blank" href="/Upload/Career/'+convert(varchar, CareerId)+'/'+vacancyDocument+'">View Document</a>' 
	  else
	  'No Document'
	  end)	ViewDocuemnt
	  
	           
from cmsCareer p                     
left join cmsStatus s on p.Status=s.Prefix                        
                    
Where                
convert(date,lastDateOfCollection,103) <= convert(date,GETDATE(),103)    
and ((CareerId=@CareerId and @CareerId is not null) or @CareerId is null)   
  
and ((depName=@DepartmentId and @DepartmentId is not null) or @DepartmentId is null)   
order by CONVERT(date, lastDateOfCollection,103) desc  
  
  
  
--Convert ERRRR  
--update cmsCareer set lastDateOfCollection=null where lastDateOfCollection in ('-- 00:00','--2011 00:00')  
--update cmsCareer set firstAnnouncementDate=null where firstAnnouncementDate in ('select-selectMonth-selectYear','select-08-2011')  
  
--select  CONVERT(date,lastDateOfCollection,103)   
--from cmsCareer  where lastDateOfCollection not in ('-- 00:00','--2011 00:00')  
--select CONVERT(date,firstAnnouncementDate,103)   
--from cmsCareer  where firstAnnouncementDate not in ('select-selectMonth-selectYear','select-08-2011')
GO
/****** Object:  StoredProcedure [dbo].[GetClone]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetClone]    
@CloneId varchar(10)=null,  
@UserId varchar(50)=null,                            
@ActionName varchar(50)=null          
As    
Select   
    
(case when (Select r.AllowDelete from ApplicationUser as l                             
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                              
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                             
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),CloneId) + ')>Delete</a>') else '' end) as DeletePermission,                            
                            
(case when (Select r.AllowUpdate from ApplicationUser as l                             
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                              
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                             
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Clone?CloneId=' + Convert(varchar(10),CloneId) + '>Edit</a>') else '' end) as EditPermission,                            
    
* from cmsClone   
  
where ((Cloneid=@CloneId and @CloneId is not null) or @CloneId is null) 
GO
/****** Object:  StoredProcedure [dbo].[GetCloneCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE Procedure [dbo].[GetCloneCreateButton]  -- GetTenderCreateButton 'Admin','GetTender'    
@UserId varchar(50)=null,    
@ActionName varchar(50)=null    
As  
Select (case when (Select r.AllowInsert from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName='CloneManage')=1 then   
  
('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Clone">Add New Clone</a></div>') else '' end) as DeletePermission    
    
GO
/****** Object:  StoredProcedure [dbo].[GetComaplainOrFeedback]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
        --GetComaplainOrFeedback null,'Admin','GetComplain'  ,'03-03-2021' ,'03-04-2021'
CREATE procedure [dbo].[GetComaplainOrFeedback] --       
@ComplainId varchar(50)  =null   ,        
@UserId varchar(50)=null,          
@ActionName varchar(50)=null ,             
@FromDate varchar(50)=null ,             
@ToDate varchar(50)=null              
As        
Select         
(case when (Select r.AllowDelete from ApplicationUser as l           
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),ComplainId) + ')>Delete</a>') else '' end) as DeletePermission,          
          
(case when (Select r.AllowUpdate from ApplicationUser as l           
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Complain?ComplainId=' + Convert(varchar(10),ComplainId) + ' >View</a>') else '' end) as EditPermission,        
         
      
          
    p.Name,p.Email,p.UploadFileName ,p.Address,    
p.ComplainId,p.ComplainType,p.ComplainSubject,p.ComplainContent,FORMAT(p.CreatedOn,'dd-MMM-yyyy') CreatedOn         
from cmsCompainOrFeedback p         
inner join cmsStatus s on p.Status=s.Prefix            
        
Where 
((ComplainId=@ComplainId and @ComplainId is not null) or @ComplainId is null)
  and (((CONVERT(date,p.CreatedOn,103) between  convert(date,@FromDate,103) and convert(date,@ToDate,103)) and 
  @FromDate is not null and @ToDate is not null) 
  or (@FromDate is null and @ToDate is null))    
GO
/****** Object:  StoredProcedure [dbo].[GetDashboard]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetDashboard] -- GetDashboard 'Admina'  
@UserId varchar(200)=null  
As  
Begin -- Delaration  
Declare @AllTedner varchar(50)  
Declare @LiveTedner varchar(50)  
Declare @CloseTedner varchar(50)  
Declare @UnPublishTedner varchar(50)  
  
Declare @AllNews varchar(50)  
Declare @LiveNews varchar(50)  
Declare @CloseNews varchar(50)  
Declare @UnPublishNews varchar(50)  
  
  
Declare @AllPages varchar(50)  
Declare @UnPublishPages varchar(50)  
Declare @AllMenu varchar(50)  
Declare @UnPublishMenu varchar(50)  
End  
if(@UserId='Superadmin' or @UserId='Admin')  
Begin  
Set @AllTedner=(Select Count(*) from cmsTenders)  
Set @LiveTedner=(Select Count(*) from cmsTenders where  convert(date,firstAnnouncementDate,103) <= convert(date,GETDATE(),103) and convert(date,lastDateForSubmission,103) >= convert(date,GETDATE(),103))  
Set @CloseTedner=(Select Count(*) from cmsTenders where  convert(date,lastDateForSubmission,103) < convert(date,GETDATE(),103))  
Set @UnPublishTedner=(Select Count(*) from cmsTenders Where status='D')  
  
Set @AllNews=(Select Count(*) from cmsNotification)  
Set @LiveNews=(Select Count(*) from cmsNotification where  convert(date,StartDate,103) <= convert(date,GETDATE(),103) and convert(date,ExpiryDate,103) >= convert(date,GETDATE(),103))  
Set @CloseNews=(Select Count(*) from cmsNotification where  convert(date,ExpiryDate,103) < convert(date,GETDATE(),103))  
Set @UnPublishNews=(Select Count(*) from cmsNotification Where status='D')  
  
Set @AllPages=(Select Count(*) from cmsPages)  
Set @UnPublishPages=(Select Count(*) from cmsPages where ContentModifyStatus='D')  
Set @AllMenu=(Select Count(*) from cmsPublicMenu)  
Set @UnPublishMenu=(Select Count(*) from cmsPublicMenu Where status='D')  
  
Select   
@AllTedner AllTender, @LiveTedner LiveTedner,@CloseTedner CloseTedner,@UnPublishTedner UnPublishTedner,  
@AllNews AllNews, @LiveNews LiveNews,@CloseNews CloseNews,@UnPublishNews UnPublishNews,  
@AllPages AllPages, @UnPublishPages UnPublishPages,@AllMenu AllMenu,@UnPublishMenu UnPublishMenu  
End  
 else
 Begin
 Select  ''
 end
  
GO
/****** Object:  StoredProcedure [dbo].[GetDepartment]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                    
                    
CREATE procedure [dbo].[GetDepartment] -- GetDepartment null,'Admin','GetNotification'                    
@DepartmentId varchar(50)  =null   ,                    
@UserId varchar(50)=null,                      
@ActionName varchar(50)=null                          
As                    
      
Select                     
      
(case when (Select r.AllowPublish from ApplicationUser as l           
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-' + (case when p.Status = 'N' then 'success' else 'warning' end) + '"><a onclick=Block(' +  Convert(varchar(10),DepartmentId) + ',"' +p.Status + '")>' + s.StatusName + '</a></li>') else '' end) as PublishPermission     ,   
                       
(case when (Select r.AllowUpdate from ApplicationUser as l                       
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                        
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                       
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Department?DepartmentId=' + Convert(varchar(10),DepartmentId) + ' >Edit</a>') else '' end) as EditPermission,                      
                    
DepartmentId,DepartmentType,DepartmentName,Status,        
FORMAT(CreatedOn,'dd-MMM-yyyy') CreatedOn       
      
from cmsDepartment p                     
left join cmsStatus s on p.Status=s.Prefix                        
                    
Where ((DepartmentId=@DepartmentId and @DepartmentId is not null) or @DepartmentId is null)
GO
/****** Object:  StoredProcedure [dbo].[GetFAQ]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
      
CREATE procedure [dbo].[GetFAQ] -- GetFAQ null,'Admin','GetFAQ'      
@FAQId varchar(50)  =null   ,      
@UserId varchar(50)=null,        
@ActionName varchar(50)=null            
As      
Select       
(case when (Select r.AllowDelete from ApplicationUser as l         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),FAQId) + ')>Delete</a>') else '' end) as DeletePermission,        
        
(case when (Select r.AllowUpdate from ApplicationUser as l         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/FAQ?FAQId=' + Convert(varchar(10),FAQId) + ' >Edit</a>') else '' end) as EditPermission,        
        
(case when (Select r.AllowPublish from ApplicationUser as l         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.Status = 'P' then 'success' else 'warning' end) + '" onclick=Publish(' +  Convert(varchar(10),FAQId) + ',"' +p.Status + '")>' + s.StatusName +   

  
'</a>') else '' end) as PublishPermission,      
        
      QuestionHindi,AnswerHindi,
FAQId,QuestionCategory,Question,Answer,AnswerDate,Status, CreatedOn     ,UpdatedOn  
from cmsFAQ p       
inner join cmsStatus s on p.Status=s.Prefix          
      
Where ((FAQId=@FAQId and @FAQId is not null) or @FAQId is null)
GO
/****** Object:  StoredProcedure [dbo].[GetFAQPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
        
CREATE procedure [dbo].[GetFAQPublish] -- GetFAQ null,'Admin','GetFAQ'        
@language varchar(50)=null
As        
Select         
(case when @language='hi' then QuestionHindi else Question end) Question,
(case when @language='hi' then AnswerHindi else Answer end) Answer,
FAQId,QuestionCategory,AnswerDate,Status, CreatedOn,UpdatedOn    
from cmsFAQPublish p         
inner join cmsStatus s on p.Status=s.Prefix            
        
--Where ((FAQId=@FAQId and @FAQId is not null) or @FAQId is null)  
GO
/****** Object:  StoredProcedure [dbo].[GetHomeFooterSlider]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE procedure [dbo].[GetHomeFooterSlider] -- GetHomeFooterSlider null,'Admin','GetMediaGallery'  
As  
declare @html1 varchar(max),@html2 varchar(max),@html3 varchar(max),@html4 varchar(max),@html5 varchar(max),@html6 varchar(max)

set @html2='<div class="item"><div class="single-project">'
set @html3='<img src="/Upload/MediaGallery/'
set @html4='"/><div class="project-text"><a href="#">'
set @html5=' </a><h3>'
set @html6='</h3></div></div></div>'
Select @html1=Isnull(
(Select   @html2+@html3+CONVERT(varchar, MediaType)+'/'+CONVERT(varchar,MediaId)+'/'+MediaPath+@html4+MediaTitle+@html5+MediaContent+@html6

from cmsMediaGallery where MediaType=2    order by CreatedOn desc  
For XML Path('')

),'')

select @html1 html1
  
GO
/****** Object:  StoredProcedure [dbo].[GetMainSite]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetMainSite]   -- GetMainSite null,'Empty'                                   
@MainSiteId bigint=null  ,                            
@PageName varchar(100)=null                                    
as                                
  declare @Menulist nvarchar(max)                                                 
declare @MenulistHindi nvarchar(max)                                                 
                                           
declare @Ul nvarchar(max)  ,@li nvarchar(max)       ,@Subli nvarchar(max)  ,                
@SubUl nvarchar(max)  ,@SubliLink nvarchar(max) ,@SubMegaMenuLI nvarchar(max)  ,                
@SubMegaMenuHtmlUl nvarchar(max)                                                      
                
      Set @Ul=(Select MenuHtmlUL from cmsMainSitePublish where Status='I')                                          
      Set @li=(Select MenuHtmlLi from cmsMainSitePublish where Status='I')                                        
      Set @SubUl=(Select SubMenuHtmlUl from cmsMainSitePublish where Status='I')                                        
      Set @Subli=(Select SubMenuHtmlLi from cmsMainSitePublish where Status='I')                                      
      Set @SubliLink=(Select SubMenuHtmlLiLink from cmsMainSitePublish where Status='I')                                      
      Set @SubMegaMenuLI=(Select MegaMenuHtmlLi from cmsMainSitePublish where Status='I')                                      
      Set @SubMegaMenuHtmlUl=(Select SubMegaMenuHtmlUl from cmsMainSitePublish where Status='I')                                      
                                         
     BEGIN --English Menu                  
SELECT                                                                                       
@Menulist=isnull((                                      
                                      
SELECT                                        
case when (select COUNT(*) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>0 then                                  
                                      
(case when (Select count(parentId) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>8 then           
@SubMegaMenuLI+ MainMenu.MenuName +@SubMegaMenuHtmlUl else @SubUl+ MainMenu.MenuName+@Subli end)+                             
(                            
                            
SELECT                             
(case when (select COUNT(*) from cmsPublicMenuPublish subSub where ParentId=SubMenu.MenuId and Status='P')>0 then                              
(                            
                            
@SubUl+SubMenu.MenuName+@Subli+                                   
(SELECT @SubliLink+         
(case when subOfSub.LinkType='Url' then ISNULL(subOfSub.Path,'#') else  ISNULL(pSubOfSubPage.PageName,'#') end)        
+'" target="'+ISNULL(subOfSub.Target,'')+'" >' +subOfSub.MenuName+'</a>' from cmsPublicMenuPublish subOfSub                            
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId                                
                            
 where ParentId=SubMenu.MenuId    and subOfSub.Status='P'                                  
order by  Priority asc,ParentId, MenuId                                                   
FOR XML PATH('')) +'</div></li>'                                
                            
                            
                            
) else                             
                            
@SubliLink+(case when SubMenu.LinkType='Url' then ISNULL(SubMenu.Path,'#') else ISNULL(pSubPage.PageName,'#') end)        
+'" target="'+ISNULL(SubMenu.Target,'')+'">' +SubMenu.MenuName+'</a>'  end)                            
                            
                            
from cmsPublicMenuPublish SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId                                
where ParentId=MainMenu.MenuId  and  SubMenu.Status='P'                          
                            
                            
                            
order by  Priority asc,ParentId, MenuId                                                   
FOR XML PATH('')) +'</div></li>'                                      
                                      
else @li+(case when MainMenu.LinkType='Url' then ISNULL(MainMenu.Path,'#') else ISNULL(pMainPage.PageName,'#') end)        
        
+'" target="'+ISNULL(MainMenu.Target,'')+'">' +MainMenu.MenuName+'</a></li>'   end  as MenuName                                      
                                      
from cmsPublicMenuPublish MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId                                
                                
                                
where MainMenu.ParentId is null     and MainMenu.Status='P'                                  
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                                          
  FOR XML PATH('')                                      
                                      
),'')             
     END                     
                  
  BEGIN -- HINDI MENU                  
SELECT                                                                                       
@MenulistHindi=isnull((                                                                
SELECT                                        
case when (select COUNT(*) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>0 then                                  
                            
                                 
                                      
(case when (Select count(parentId) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>8 then           
@SubMegaMenuLI+ MainMenu.MenuNameHindi+@SubMegaMenuHtmlUl else @SubUl+ MainMenu.MenuNameHindi+@Subli end)+                             
(                            
                            
SELECT                             
(case when (select COUNT(*) from cmsPublicMenuPublish subSub where ParentId=SubMenu.MenuId and Status='P')>0 then                              
(                            
                            
@SubUl+SubMenu.MenuNameHindi+@Subli+                                   
(SELECT @SubliLink+(case when subOfSub.LinkType='Url' then ISNULL(subOfSub.Path,'#') else  ISNULL(pSubOfSubPage.PageName,'#') end)        
+'" target="'+ISNULL(subOfSub.Target,'')+'">' +subOfSub.MenuNameHindi+'</a>' from cmsPublicMenuPublish subOfSub                            
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId                                
                            
 where ParentId=SubMenu.MenuId          and  subOfSub.Status='P'                              
order by  Priority asc,ParentId, MenuId                                                   
FOR XML PATH('')) +'</div></li>'                                
                       
                            
                            
) else                             
                            
@SubliLink+(case when SubMenu.LinkType='Url' then ISNULL(SubMenu.Path,'#') else  ISNULL(pSubPage.PageName,'#') End)        
        
+'" target="'+ISNULL(SubMenu.Target,'')+'">' +SubMenu.MenuNameHindi+'</a>'  end)                            
                            
                            
from cmsPublicMenuPublish SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId                                
where ParentId=MainMenu.MenuId and  SubMenu.Status='P'                             
                            
                            
                            
order by  Priority asc,ParentId, MenuId                                                   
FOR XML PATH('')) +'</div></li>'                               
                                      
else @li+(case when MainMenu.LinkType='Url' then ISNULL(MainMenu.Path,'#') else  ISNULL(pMainPage.PageName,'#') End)        +'" target="'+ISNULL(MainMenu.Target,'')+'">' +MainMenu.MenuNameHindi+'</a></li>'   end  as MenuName                              
        
                                      
from cmsPublicMenuPublish MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId                                
                                
                                
where MainMenu.ParentId is null     and MainMenu.Status='P'                                  
      order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                                                 
  FOR XML PATH('')                                      
                                      
),'')                                
        END                  
                  
declare @Lastupdate varchar(20)=null     ,                   
@MetaData varchar(200)=null                        
                       
Set @MetaData= (Select '<meta title="'+MetaTitle+'"  content="'+MetaContent+'" />' from cmsPagesPublish where PageName=@PageName)                  
set @Lastupdate=(Select case when UpdatedOn is null then Format (CreatedOn,'dd-MMM-yyyy hh:mm tt') else Format (UpdatedOn,'dd-MMM-yyyy hh:mm tt') end  from cmsPagesPublish where PageName=@PageName)                                  
Select @Lastupdate Lastupdate, @Menulist MenuList,@MenulistHindi MenulistHindi,                   
       MainSiteId,ThemeName,                  
    HeadTag+ISNULL(@MetaData,'')+'</head>' HeadTag,                  
                      
    FooterScript,Header,HeaderHindi,BeforeManuHeader,AfterManuHeader,Breadcrumbs                  
      ,InnerPageStart,InnerPageEnd,ContentStart,ContenEnd,Footer,FooterHindi,Body,Slider,PublicMenu                  
      ,Pages,MenuHtmlUL,MenuHtmlLi,SubMenuHtmlUl,SubMenuHtmlLi,SubMenuHtmlLiLink,Status,StatusPublish                  
      ,CreatedBy,CreatedOn,CIPAddress,UpdatedBy,UpdatedOn,UIPAddress                  
                  
from cmsMainSitePublish                       
                                      
Where Status='I' and ((MainSiteId=@MainSiteId and @MainSiteId is not null) or @MainSiteId is null)   
GO
/****** Object:  StoredProcedure [dbo].[GetMainSiteAdminAdd]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure  [dbo].[GetMainSiteAdminAdd]  
@MainSiteId varchar(50)=null  
as  
Select top 1 MainSiteId  
      ,ThemeName  
      ,HeadTag  
      ,FooterScript  
      ,Header  
      ,HeaderHindi  
      ,BeforeManuHeader  
      ,AfterManuHeader  
      ,Breadcrumbs  
      ,InnerPageStart  
      ,InnerPageEnd  
      ,ContentStart  
      ,ContenEnd  
      ,Footer  
      ,FooterHindi  
      ,Body  
      ,Slider  
      ,PublicMenu  
      ,Pages  
      ,MenuHtmlUL  
      ,MenuHtmlLi  
      ,SubMenuHtmlUl  
      ,SubMenuHtmlLi  
      ,SubMenuHtmlLiLink  
      ,MegaMenuHtmlLi  
      ,SubMegaMenuHtmlUl  
      ,StatusPublish  
      ,Status  
      ,CreatedBy  
      ,CreatedOn  
      ,CIPAddress  
      ,UpdatedBy  
      ,UpdatedOn  
      ,UIPAddress  
   from cmsMainSite where  
   ((MainSiteId=@MainSiteId and @MainSiteId is not null) or @MainSiteId is null)
GO
/****** Object:  StoredProcedure [dbo].[GetMainSiteForAdmin]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetMainSiteForAdmin]   -- GetMainSite null,'Empty'                       
@MainSiteId bigint=null  ,                
@PageName varchar(100)=null                        
as                    
  declare @Menulist nvarchar(max)                                     
declare @MenulistHindi nvarchar(max)                                     
                               
declare @Ul nvarchar(max)  ,@li nvarchar(max)       ,@Subli nvarchar(max)  ,    
@SubUl nvarchar(max)  ,@SubliLink nvarchar(max) ,@SubMegaMenuLI nvarchar(max)  ,    
@SubMegaMenuHtmlUl nvarchar(max)                                          
    
      Set @Ul=(Select MenuHtmlUL from cmsMainSite where Status='I')                              
      Set @li=(Select MenuHtmlLi from cmsMainSite where Status='I')                            
      Set @SubUl=(Select SubMenuHtmlUl from cmsMainSite where Status='I')                            
      Set @Subli=(Select SubMenuHtmlLi from cmsMainSite where Status='I')                          
      Set @SubliLink=(Select SubMenuHtmlLiLink from cmsMainSite where Status='I')                          
      Set @SubMegaMenuLI=(Select MegaMenuHtmlLi from cmsMainSite where Status='I')                          
      Set @SubMegaMenuHtmlUl=(Select SubMegaMenuHtmlUl from cmsMainSite where Status='I')                          
                             
     BEGIN --English Menu      
SELECT                                                                           
@Menulist=isnull((                          
                          
SELECT                            
case when (select COUNT(*) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId)>0 then                      
                          
(case when (Select count(parentId) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId)>8 then @SubMegaMenuLI+ MainMenu.MenuName+@SubMegaMenuHtmlUl else @SubUl+ MainMenu.MenuName+@Subli end)+                 
(                
                
SELECT                 
(case when (select COUNT(*) from cmsPublicMenuPublish subSub where ParentId=SubMenu.MenuId)>0 then                  
(                
                
@SubUl+SubMenu.MenuName+' +'+@Subli+                       
(SELECT @SubliLink+ISNULL(pSubOfSubPage.PageName,'#')+'">' +subOfSub.MenuName+'</a></li>' from cmsPublicMenuPublish subOfSub                
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId                    
                
 where ParentId=SubMenu.MenuId                          
order by  Priority asc,ParentId, MenuId                                       
FOR XML PATH('')) +'</ul></li>'                    
                
                
                
) else                 
                
@SubliLink+ISNULL(pSubPage.PageName,'#')+'">' +SubMenu.MenuName+'</a></li>'  end)                
                
                
from cmsPublicMenuPublish SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId                    
where ParentId=MainMenu.MenuId                           
                
                
                
order by  Priority asc,ParentId, MenuId                                       
FOR XML PATH('')) +'</ul></li>'                          
                          
else @li+ISNULL(pMainPage.PageName,'#')+'">' +MainMenu.MenuName+'</a></li>'   end  as MenuName                          
                          
from cmsPublicMenuPublish MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId                    
                    
                    
where MainMenu.ParentId is null     and MainMenu.Status='P'                      
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                                     
  FOR XML PATH('')                          
                          
),'')                        
     END         
      
  BEGIN -- HINDI MENU      
SELECT                                                                           
@MenulistHindi=isnull((                                                    
SELECT                            
case when (select COUNT(*) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId)>0 then                      
                
                     
                          
(case when (Select count(parentId) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId)>8 then @SubMegaMenuLI+ MainMenu.MenuNameHindi+@SubMegaMenuHtmlUl else @SubUl+ MainMenu.MenuNameHindi+@Subli end)+                 
(                
                
SELECT                 
(case when (select COUNT(*) from cmsPublicMenuPublish subSub where ParentId=SubMenu.MenuId)>0 then                  
(                
                
@SubUl+SubMenu.MenuNameHindi+' +'+@Subli+                       
(SELECT @SubliLink+ISNULL(pSubOfSubPage.PageName,'#')+'">' +subOfSub.MenuNameHindi+'</a></li>' from cmsPublicMenuPublish subOfSub                
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId                    
                
 where ParentId=SubMenu.MenuId                          
order by  Priority asc,ParentId, MenuId                                       
FOR XML PATH('')) +'</ul></li>'                    
           
                
                
) else                 
                
@SubliLink+ISNULL(pSubPage.PageName,'#')+'">' +SubMenu.MenuNameHindi+'</a></li>'  end)                
                
                
from cmsPublicMenuPublish SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId                    
where ParentId=MainMenu.MenuId                           
                
                
                
order by  Priority asc,ParentId, MenuId                                       
FOR XML PATH('')) +'</ul></li>'                   
                          
else @li+ISNULL(pMainPage.PageName,'#')+'">' +MainMenu.MenuNameHindi+'</a></li>'   end  as MenuName                          
                          
from cmsPublicMenuPublish MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId                    
                    
                    
where MainMenu.ParentId is null     and MainMenu.Status='P'                      
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                                     
  FOR XML PATH('')                          
                          
),'')                    
        END      
      
declare @Lastupdate varchar(20)=null     ,       
@MetaData varchar(200)=null            
           
Set @MetaData= (Select '<meta title="'+MetaTitle+'"  content="'+MetaContent+'" />' from cmsPagesPublish where PageName=@PageName)      
set @Lastupdate=(Select case when UpdatedOn is null then Format (CreatedOn,'dd-MMM-yyyy hh:mm tt') else Format (UpdatedOn,'dd-MMM-yyyy hh:mm tt') end  from cmsPagesPublish where PageName=@PageName)                      
Select @Lastupdate Lastupdate, @Menulist MenuList,@MenulistHindi MenulistHindi,       
       MainSiteId,ThemeName,      
    HeadTag+ISNULL(@MetaData,'')+'</head>' HeadTag,      
          
    FooterScript,Header,HeaderHindi,BeforeManuHeader,AfterManuHeader,Breadcrumbs      
      ,InnerPageStart,InnerPageEnd,ContentStart,ContenEnd,Footer,FooterHindi,Body,Slider,PublicMenu      
      ,Pages,MenuHtmlUL,MenuHtmlLi,SubMenuHtmlUl,SubMenuHtmlLi,SubMenuHtmlLiLink,Status,StatusPublish      
      ,CreatedBy,CreatedOn,CIPAddress,UpdatedBy,UpdatedOn,UIPAddress      
      
from cmsMainSite                          
                          
Where Status='I' and ((MainSiteId=@MainSiteId and @MainSiteId is not null) or @MainSiteId is null) 
GO
/****** Object:  StoredProcedure [dbo].[GetMediaGallery]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
        
CREATE procedure [dbo].[GetMediaGallery] -- GetMediaGallery null,'Admin','GetMediaGallery'        
@MediaId varchar(50)  =null   ,        
@MediaCategory varchar(50)  =null   ,        
@MediaType varchar(50)  =null   ,        
@UserId varchar(50)=null,          
@ActionName varchar(50)=null              
As        
Select         
(case when (Select r.AllowDelete from ApplicationUser as l           
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),MediaId) + ')>Delete</a>') else '' end) as DeletePermission,          
          
(case when (Select r.AllowUpdate from ApplicationUser as l           
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/MediaGallery?MediaId=' + Convert(varchar(10),MediaId) + ' >Edit</a>') else '' end) as EditPermission,          
          
--(case when (Select r.AllowPublish from ApplicationUser as l           
--inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
--inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
--where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.Status = 'P' then 'success' else 'warning' end) + '" onclick=Publish(' +  Convert(varchar(10),MediaId) + ',"' +p.Status + '")>' + s.StatusName 
+   
    
      
--'</a>') else '' end) as PublishPermission,        
          
        
MediaId,MediaContent,MediaPath,MediaTitle,MediaCategory,MediaTitleHindi,MediaContentHindi, 
Version,FileSize,   
p.MediaType,FORMAT(CreatedOn,'dd-MMM-yyyy') CreatedOn   ,      
t.MediaType MediaTypeName      
from cmsMediaGallery p         
inner join cmsStatus s on p.Status=s.Prefix            
inner join cmsMediaGalleryType t on p.MediaType=t.Id            
        
Where   
((MediaId=@MediaId and @MediaId is not null) or @MediaId is null)  
and ((MediaCategory=@MediaCategory and @MediaCategory is not null) or @MediaCategory is null)  
and ((p.MediaType=@MediaType and @MediaType is not null) or @MediaType is null)  
GO
/****** Object:  StoredProcedure [dbo].[GetNotification]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                            
                            
CREATE procedure [dbo].[GetNotification] -- GetNotification null,'Admin','GetNotification'                            
@NotificationId varchar(50)  =null   ,                            
@Type varchar(50)  =null   ,                            
@UserId varchar(50)=null,                              
@ActionName varchar(50)=null    ,
@FromDate varchar(50)=null ,               
@ToDate varchar(50)=null                                 
As                            
declare @pageId varchar(20)=null,@pagename varchar(20)=null              
set @pagename='Index'              
              
set @pageId=(select pageId from cmsPages where PageName=@pagename)              
              
Select                             
              
(case when (Select r.AllowDelete from ApplicationUser as l                               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),NotificationId) + ')>Delete</a>') else '' end) as DeletePermission,                              
                              
(case when (Select r.AllowUpdate from ApplicationUser as l                               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Notification?NotificationId=' + Convert(varchar(10),NotificationId) + ' >Edit</a>') else '' end) as EditPermission,                         
  
    
     
                              
(case when (Select r.AllowPublish from ApplicationUser as l                               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.Status = 'P' then 'success' else 'warning' end) + '" onclick=Publish(' +  Convert(varchar(10),NotificationId) + ',"' +p.Status + '")>' + s.StatusName +                       
                      
                        
'</a>') else '' end) as PublishPermission,                            
                    Type, PageId,Path,LinkType,Target,Priority,  NewGIF,           
                            
NotificationId,Description,Status,    DescriptionHindi,            
FORMAT(CreatedOn,'dd-MMM-yyyy') CreatedOn,                
FORMAT(ExpiryDate,'dd-MMM-yyyy') ExpiryDate,                  
FORMAT(UpdatedOn,'dd-MMM-yyyy') UpdatedOn  ,                
FORMAT(StartDate,'dd-MMM-yyyy') StartDate             
--,@pageId pageId ,@pagename PageName              
from cmsNotification p                             
inner join cmsStatus s on p.Status=s.Prefix                                
                            
Where       
((NotificationId=@NotificationId and @NotificationId is not null) or @NotificationId is null)       
and ((Type=@Type and @Type is not null) or @Type is null) 
  and (((CONVERT(date,p.CreatedOn,103) between  convert(date,@FromDate,103) and convert(date,@ToDate,103)) and   
  @FromDate is not null and @ToDate is not null)   
  or (@FromDate is null and @ToDate is null)) 
GO
/****** Object:  StoredProcedure [dbo].[GetNotificationForHomePage]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
              
CREATE procedure [dbo].[GetNotificationForHomePage]   -- GetNotificationForHomePage 'Index'              
@Language varchar(10)=null          
as                      
declare @SpotLights nvarchar(max)         
declare @Notices nvarchar(max)         
declare @BusinessReform nvarchar(max)         
declare @TenderNotice nvarchar(max)         
      
Begin -- SlotLight      
SELECT                                                                 
@SpotLights=isnull((              
                
SELECT         
Case when p.NewGIF='false' then '' else  p.NewGIF+'&nbsp;&nbsp;' end               
+      
      
'<a href="'+case when p.LinkType='Url' then Path         
else (Select PageName from cmsPagesPublish where PageId=p.PageId) end+         
'" target="'+Target+'" >'+         
(case when @Language='hi' then p.DescriptionHindi else p.Description end)+'</a>&nbsp; &nbsp; &nbsp; &nbsp;'        
             
 from cmsNotificationPublish p where    Type='Spotlight' and        
-- convert(date,StartDate,103) <= convert(date,GETDATE(),103)             
--and             
--convert(date,ExpiryDate,103) >= convert(date,GETDATE(),103)              
--  and   
  Status='P'               
              
        order by Priority,CreatedOn desc              
  FOR XML PATH('')                
                
),'')                
End      
      
Begin -- Notices      
SELECT                                                                 
@Notices=isnull((              
                
SELECT                  
'<li class="news-item"><a href="'+case when p.LinkType='Url' then Path         
else (Select PageName from cmsPagesPublish where PageId=p.PageId) end+         
'" target="'+Target+'">'+         
(case when @Language='hi' then p.DescriptionHindi else p.Description end)+      
(Case when p.NewGIF='false' then '' else  '&nbsp;&nbsp;'+p.NewGIF end)+           
'</a></li>'       
          
       
             
 from cmsNotificationPublish p where    Type='Notices' and        
-- convert(date,StartDate,103) <= convert(date,GETDATE(),103)             
--and             
--convert(date,ExpiryDate,103) >= convert(date,GETDATE(),103)              
--   and   
   Status='P'                      
              
        order by Priority,CreatedOn desc              
  FOR XML PATH('')                
                
),'')                
End      
      
Begin -- BusinessReform      
SELECT                                                                 
@BusinessReform=isnull((              
                
SELECT                  
'<li class="news-item"><a href="'+case when p.LinkType='Url' then Path         
else (Select PageName from cmsPagesPublish where PageId=p.PageId) end+         
'" target="'+Target+'">'+         
(case when @Language='hi' then p.DescriptionHindi else p.Description end)+      
Case when p.NewGIF='false' then '' else  '&nbsp;&nbsp;'+p.NewGIF end     +      
'</a></li>'        
             
 from cmsNotificationPublish p where    Type='BusinessReform' and        
-- convert(date,StartDate,103) <= convert(date,GETDATE(),103)             
--and             
--convert(date,ExpiryDate,103) >= convert(date,GETDATE(),103)              
--   and   
   Status='P'               
              
        order by Priority,CreatedOn desc              
  FOR XML PATH('')                
                
),'')                
End      
      
Begin -- TenderNotice      
SELECT                                                                 
@TenderNotice=isnull((              
                
SELECT                  
'<li class="news-item"><a href="'+case when p.LinkType='Url' then Path         
else (Select PageName from cmsPagesPublish where PageId=p.PageId) end+         
'" target="'+Target+'">'+         
(case when @Language='hi' then p.DescriptionHindi else p.Description end)+      
 (Case when p.NewGIF='false' then '' else  '&nbsp;&nbsp;'+p.NewGIF end) +          
'</a></li>'       
             
 from cmsNotificationPublish p where    Type='TenderNotice' and        
-- convert(date,StartDate,103) <= convert(date,GETDATE(),103)             
--and             
--convert(date,ExpiryDate,103) >= convert(date,GETDATE(),103)              
--  and   
    
  Status='P'                   
              
        order by Priority, CreatedOn desc              FOR XML PATH('')                
                
),'')                
End      
      
Select @SpotLights HomeshowSpotLights ,      
       @Notices HomeShowNotice ,             
    @BusinessReform HomeShowBusinessForm ,      
    @TenderNotice HomeShowTenderNotice    
GO
/****** Object:  StoredProcedure [dbo].[GetNotificationForHomePageForView]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[GetNotificationForHomePageForView]   -- GetNotificationForHomePage 'Index'  
@NotificationId bigint=null
as          
declare @Newslist nvarchar(max)               
         
declare @NewsUpdateIndexPage nvarchar(max)=null,@NewsUpdateIndexPage2 nvarchar(max)=null,@NewsUpdateIndexPage3 nvarchar(max)=null,@NewsUpdateIndexPage4 nvarchar(max)=null  
Set  @NewsUpdateIndexPage=' <li><a href="javascript:void(0)"><div class="post_grid"><div class="post_date">'  
Set  @NewsUpdateIndexPage2='<div class="month">'  
Set  @NewsUpdateIndexPage3='</div></div><div class="post_body"><h4 class="post_title">'  
Set  @NewsUpdateIndexPage4='</div></div></a></li>'  
       
    
SELECT                                                     
@Newslist=isnull((  
    
SELECT      
@NewsUpdateIndexPage+CAST(DAY(CreatedOn) as varchar) +@NewsUpdateIndexPage2+CAST(FORMAT((CreatedOn),'MMM') as varchar)+' '+ CAST(Year(CreatedOn) as varchar)  
 +@NewsUpdateIndexPage3+Description+@NewsUpdateIndexPage4  
 from cmsNotification where 
 ((NotificationId=@NotificationId and @NotificationId is not null) or @NotificationId is null) and convert(date,ExpiryDate,103) >= convert(date,GETDATE(),103)  
        order by CreatedOn desc  
  FOR XML PATH('')    
    
),'')           
Select @Newslist Newslist
GO
/****** Object:  StoredProcedure [dbo].[GetPages]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                    
CREATE procedure [dbo].[GetPages]          -- GetPages 'Tenders','en'                              
@PageName varchar(50)  =null  ,                      
@Language varchar(50)  =null                                     
as              
Begin -- Declaration                                    
declare @BreadCrum nvarchar(max),@MenuName nvarchar(200),@PageTitle nvarchar(200)=null ,@MenuNameBread nvarchar(200),   @BreadCupWithoutMenu nvarchar(max),   @SideMenu nvarchar(max),@SideMenuHindi nvarchar(max),                          
@MenuId nvarchar(200)=null ,@ParentId nvarchar(200)=null ,@SubParentId nvarchar(200)=null ,@SubMenuName nvarchar(200)=null,@SubOfSubMenuName nvarchar(200)=null                          
Set @MenuName=(Select top 1 (case when @Language='hi' then MenuNameHindi else MenuName end) from cmsPublicMenuPublish m left join cmsPages p on m.PageId=p.PageId where PageName=@PageName)                                
Set @PageTitle=(Select (case when @Language='hi' then PageTitleHindi else PageTitle end) PageTitle from cmsPagesPublish where PageName=@PageName)                               
                
Set @MenuId= (Select top 1  MenuId from cmsPublicMenuPublish m left join cmsPages p on m.PageId=p.PageId where PageName=@PageName)                         
Set @ParentId= (Select top 1 ParentId from cmsPublicMenuPublish m left join cmsPages p on m.PageId=p.PageId where PageName=@PageName)                         
Set @SubParentId= (Select  top 1 ParentId from cmsPublicMenuPublish m left join cmsPages p on m.PageId=p.PageId where MenuId=@ParentId)                         
                
Set @MenuNameBread= (Select  top 1 (case when @Language='hi' then MenuNameHindi else MenuName end) from cmsPublicMenuPublish m left join cmsPages p on m.PageId=p.PageId where PageName=@PageName)                         
Set @SubMenuName= (Select top 1 (case when @Language='hi' then MenuNameHindi else MenuName end) from cmsPublicMenuPublish m left join cmsPages p on m.PageId=p.PageId where ParentId=@ParentId)                         
Set @SubOfSubMenuName= (Select top 1 (case when @Language='hi' then MenuNameHindi else MenuName end) from cmsPublicMenuPublish m left join cmsPages p on m.PageId=p.PageId where MenuId=@SubParentId)                         
End        
Begin -- Side Menu          
Select @SideMenu=menuEnglish,@SideMenuHindi=menuHindi from dbo.MenuList(@PageName)          
end          
Begin -- Breadcrum          
   
set @BreadCrum='<section class="">  
    <div class="container-fluid">  
        <div class="row">  
            <div class="col  pl-0 pr-0">  
                <div class="about_banner common-heading">  
                    <div class="main_heaading">  
                        <h4>'+ISNULL(@MenuName,@PageTitle)+'</h4>  
						'+(Select  top 1            
  (case when p.ParentID is null then             
  '<h5>'+ISNULL(@MenuName,@PageTitle)+' &nbsp;&nbsp;
						|&nbsp;&nbsp;<span><a href="#"> Nमुख्य पृष्ठ </a></span></h5>  '+            
  ISNULL(@MenuName,@PageTitle)+'</span>'             
  else             
   '<h5>'+            
  (Select top 1 (case when @Language='hi' then ISNULL(MenuNameHindi,@PageTitle)  else  ISNULL(MenuName,@PageTitle) end) from cmsPublicMenuPublish where MenuId=p.ParentId)            
  +'&nbsp;&nbsp;|&nbsp;&nbsp;<span><a href="#">'+            
  +ISNULL(@MenuName,@PageTitle)++'</a></span></h5>'  end)             
  from cmsPublicMenuPublish p where MenuId=@MenuId)+'
                        
                    </div>  
                </div>  
            </div>  
        </div>  
    </div>  
</section>'    
set @BreadCupWithoutMenu='<section class="">  
    <div class="container-fluid">  
        <div class="row">  
            <div class="col  pl-0 pr-0">  
                <div class="about_banner common-heading">  
                    <div class="main_heaading">  
                        <h4>'+@PageTitle+'</h4>  
                    </div>  
                </div>  
            </div>  
        </div>  
    </div>  
</section>'   
                                    
end                           
                                    
                                
Select     @MenuName MenuName,      
(case when @Language='hi' then  @SideMenuHindi else   @SideMenu end ) SideMenu,          
PageId,        
case when @PageName!='Index'         
then ISNULL(@BreadCrum,@BreadCupWithoutMenu) +         
Isnull((Select (case when @Language='hi' then PageContentHindi else PageContent end) from cmsPagesPublish where PageName='HomePageOtherLing'),'')+        
((case when @Language='hi' then PageContentHindi else PageContent end)) else           
Isnull((Select (case when @Language='hi' then PageContentHindi else PageContent end) from cmsPagesPublish where PageName='HomePageOtherLing'),'')+        
((case when @Language='hi' then PageContentHindi else PageContent end)) end  PageContent                  
,PageName ,ISNULL(@BreadCrum,@BreadCupWithoutMenu) BreadCrum                             
,PageTitle    ,s.StatusName   ,(case when UpdatedOn is null then CreatedOn else UpdatedOn end) UpdatedOn                           
,p.Status from cmsPagesPublish p                                    
inner join cmsStatus s on p.Status=s.Prefix                                       
Where p.Status ='P' and                                     
((PageName=@PageName  and @PageName is not null) or @PageName is null)                                     
 order by PageId desc 
GO
/****** Object:  StoredProcedure [dbo].[GetPagesAudittrainByAdmin]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
         
-- GetPagesAudittrainByAdmin  null,'2021-03-26','2021-03-26'  
CREATE procedure [dbo].[GetPagesAudittrainByAdmin]    
@SearchContent varchar(100)  =null  ,      
@FromDate varchar(50)=null  ,          
@ToDate varchar(50)=null                          
as                                    
Select                           
                    
'<a class="btn btn-info" href="/Admin/Pages?CID=' + Convert(varchar(10),p.PageId) + '">Clone Me!</a>' as InsertPermission,                            
                           
                          
      p.PageId ,        p.DepartmentId,       p.MetaTitle,p.MetaContent,       
   p.UpdatedBy,      
   p.CreatedBy,  
     p.ActionName  ,           
     p.ActionBy  ,           
     p.ActionOn  ,           
      p.PageContent  ,p.PageContentHindi,p.PageTitleHindi,                          
   FORMAT(p.CreatedOn,'dd-MMM-yyy hh:mm:s tt') CreatedOn,                      
   FORMAT(p.UpdatedOn,'dd-MMM-yyy hh:mm:s tt') UpdatedOn,                      
      p.PageName,                         
      p.PageTitle,                      
   s.StatusName ,                             
      p.Status ,                      
   case when pp.UpdatedOn is null then  FORMAT(pp.CreatedOn,'dd-MMM-yyyy  hh:mm:s tt') else  FORMAT(pp.UpdatedOn,'dd-MMM-yyyy hh:mm:s tt') end PublishedOn                      
                         
   from cmsPagesHistory p                              
inner join cmsStatus s on p.ContentModifyStatus=s.Prefix                                 
left join cmsPagesPublish pp on p.PageId=pp.PageId                                 
Where               
                                                       
((p.PageName like '%'+@SearchContent+'%'     
or p.CreatedBy like '%'+@SearchContent+'%'     
or p.UpdatedBy like '%'+@SearchContent+'%'     
and @SearchContent is not null) or @SearchContent is null)     
  
and   
  
((CONVERT(date,p.UpdatedOn,103) between @FromDate and @ToDate  
and @FromDate is not null and @ToDate is not null) or @FromDate is null or @ToDate is null)  
  
  
or ((CONVERT(date,p.CreatedOn,103) between @FromDate and @ToDate  
and @FromDate is not null and @ToDate is not null) or @FromDate is null or @ToDate is null)  
  
 order by case when p.UpdatedOn is null then p.CreatedOn else p.UpdatedOn end desc 
GO
/****** Object:  StoredProcedure [dbo].[GetPagesByAdmin]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                          
CREATE procedure [dbo].[GetPagesByAdmin]   -- GetPagesByAdmin null,'O',null,'Admin','1,2,3,4','PagesManage','P'                             
@PageName varchar(100)  =null  ,                          
@SearchContent varchar(100)  =null  ,                          
@PageId varchar(50)  =null   ,                      
@UserId varchar(50)=null,                   
@DepartmentId varchar(250),          
@ActionName varchar(50)=null  ,      
@Status varchar(100)=null                         
as                                
Select                       
                        
(case when (Select r.AllowDelete from ApplicationUser as l                         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),p.PageId) + ')>Delete</a>') else '' end) as DeletePermission,                        
                        
(case when (Select r.AllowUpdate from ApplicationUser as l                         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Pages?PageId=' + Convert(varchar(10),p.PageId) + ' >Edit</a>') else '' end) as EditPermission,                        
                        
(case when (Select r.AllowPublish from ApplicationUser as l                         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.ContentModifyStatus = 'P' then 'success' else 'warning' end) + '" onclick=Publish(' +  Convert(varchar(10),p.PageId) + ',"' +p.ContentModifyStatus                   
+ '")>' + s.StatusName + '                    
</a>') else '' end) as PublishPermission,                 
              
(case when (Select r.AllowInsert from ApplicationUser as l                         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-info" href="/Admin/Pages?CID=' + Convert(varchar(10),p.PageId) + '">Clone Me!</a>') else '' end) as InsertPermission,                        
                       
                      
      p.PageId ,        p.DepartmentId,       p.MetaTitle,p.MetaContent,   
   p.UpdatedBy,  
   p.CreatedBy,           
      p.PageContent  ,p.PageContentHindi,p.PageTitleHindi,                      
   FORMAT(p.CreatedOn,'dd-MMM-yyy hh:mm:s tt') CreatedOn,                  
   FORMAT(p.UpdatedOn,'dd-MMM-yyy hh:mm:s tt') UpdatedOn,                  
      p.PageName,                     
      p.PageTitle,                  
   s.StatusName ,                         
      p.Status ,                  
   case when pp.UpdatedOn is null then  FORMAT(pp.CreatedOn,'dd-MMM-yyyy  hh:mm:s tt') else  FORMAT(pp.UpdatedOn,'dd-MMM-yyyy hh:mm:s tt') end PublishedOn                  
                     
   from cmsPages p                          
inner join cmsStatus s on p.ContentModifyStatus=s.Prefix                             
left join cmsPagesPublish pp on p.PageId=pp.PageId                             
Where           
p.DepartmentId in(select value from dbo.fn_Split(@DepartmentId,',')) and        
                
((p.ContentModifyStatus=@Status  and @Status is not null) or @Status is null) and                          
((p.PageName=@PageName  and @PageName is not null) or @PageName is null) and                          
((p.PageName like '%'+@SearchContent+'%'   and @SearchContent is not null) or @SearchContent is null) and                          
((p.PageId=@PageId  and @PageId is not null) or @PageId is null) order by 
case when p.UpdatedOn is null then p.CreatedOn  else p.UpdatedOn end
 desc 
GO
/****** Object:  StoredProcedure [dbo].[GetPagesForHome]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
CREATE procedure [dbo].[GetPagesForHome]            
@PageName varchar(50)  =null  ,      
@PageId varchar(50)  =null   ,  
@UserId varchar(50)=null,    
@ActionName varchar(50)=null       
as            
Select   
    
(case when (Select r.AllowDelete from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),PageId) + ')>Delete</a>') else '' end) as DeletePermission,    
    
(case when (Select r.AllowUpdate from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Pages?PageId=' + Convert(varchar(10),p.PageId) + ' >Edit</a>') else '' end) as EditPermission,    
    
(case when (Select r.AllowPublish from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.Status = 'P' then 'success' else 'warning' end) + '" onclick=Publish(' +  Convert(varchar(10),PageId) + ',"' +p.Status + '")>' + s.StatusName + '
</a>') else '' end) as PublishPermission,  
    
  
  
PageId          
      ,PageContent  ,    p.CreatedOn,p.UpdatedOn    
      ,PageName          
      ,PageTitle    ,s.StatusName      
      ,p.Status from cmsPages p      
inner join cmsStatus s on p.Status=s.Prefix         
Where      p.Status='P' 
order by PageId desc      
GO
/****** Object:  StoredProcedure [dbo].[GetPagesForView]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                  
CREATE procedure [dbo].[GetPagesForView]          -- GetPagesForView 'Career', 27              
@PageName varchar(50)    ,    
@PageId varchar(50) =null     
as                        
declare @BreadCrum varchar(max),@MenuName varchar(200), @InnerPageStart varchar(max), @InnerPageEnd varchar(max)              
Set @MenuName=(Select top 1 MenuName from cmsPublicMenu m left join cmsPages p on m.PageId=p.PageId where PageName=@PageName)              
Set @InnerPageStart=(Select InnerPageStart from cmsMainSite where Status='I')              
set @InnerPageEnd=(Select InnerPageEnd from cmsMainSite where Status='I')              
              
              
              
              
Select                 
              
PageId                      
            
      ,case when @PageName!='Index' then ISNULL(@BreadCrum,'') +PageContent else PageContent end  PageContent                      
      ,PageName                      
      ,PageTitle    ,s.StatusName   ,(case when UpdatedOn is null then CreatedOn else UpdatedOn end) UpdatedOn         
      ,p.Status from cmsPages p                  
inner join cmsStatus s on p.Status=s.Prefix                     
Where 
((PageId=@PageId and @PageId is not null) or @PageId is null)                 
and ((PageName=@PageName and @PageName is not null) or @PageName is null)                 
 order by PageId desc 
GO
/****** Object:  StoredProcedure [dbo].[GetPublicMenu]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetPublicMenu]   -- GetPublicMenu               
as                  
declare @Menulist nvarchar(max)                       
declare @MenulistHindi nvarchar(max)                       
                 
declare @Ul nvarchar(max)  ,@li nvarchar(max)       ,@Subli nvarchar(max)  ,@SubUl nvarchar(max)  ,@SubliLink nvarchar(max)                  
      Set @Ul=(Select MenuHtmlUL from cmsMainSite where Status='I')                
      Set @li=(Select MenuHtmlLi from cmsMainSite where Status='I')              
      Set @SubUl=(Select SubMenuHtmlUl from cmsMainSite where Status='I')              
      Set @Subli=(Select SubMenuHtmlLi from cmsMainSite where Status='I')            
      Set @SubliLink=(Select SubMenuHtmlLiLink from cmsMainSite where Status='I')            
               
            
SELECT                                                             
@Menulist=isnull((            
            
SELECT              
case when (select COUNT(*) from cmsPublicMenu where ParentId=MainMenu.MenuId)>0 then        
  
       
            
@SubUl+MenuName+@Subli+   
(  
  
SELECT   
(case when (select COUNT(*) from cmsPublicMenu subSub where ParentId=SubMenu.MenuId)>0 then    
(  
  
@SubUl+MenuName+@Subli+         
(SELECT @SubliLink+ISNULL(pSubOfSubPage.PageName,'#')+'">' +subOfSub.MenuName+'</a></li>' from cmsPublicMenu subOfSub  
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId      
  
 where ParentId=SubMenu.MenuId            
order by  Priority asc,ParentId, MenuId                         
FOR XML PATH('')) +'</ul></li>'      
  
  
  
) else   
  
@SubliLink+ISNULL(pSubPage.PageName,'#')+'">' +MainMenu.MenuName+'</a></li>'  end)  
  
  
from cmsPublicMenu SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId      
where ParentId=MainMenu.MenuId             
  
  
  
order by  Priority asc,ParentId, MenuId                         
FOR XML PATH('')) +'</ul></li>'            
            
else @li+ISNULL(pMainPage.PageName,'#')+'">' +MainMenu.MenuName+'</a></li>'   end  as MenuName            
            
from cmsPublicMenu MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId      
      
      
where MainMenu.ParentId is null     and MainMenu.Status='P'        
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                       
  FOR XML PATH('')            
            
),'')          

SELECT                                                             
@MenulistHindi=isnull((            
            
SELECT              
case when (select COUNT(*) from cmsPublicMenu where ParentId=MainMenu.MenuId)>0 then        
  
       
            
@SubUl+MenuName+@Subli+   
(  
  
SELECT   
(case when (select COUNT(*) from cmsPublicMenu subSub where ParentId=SubMenu.MenuId)>0 then    
(  
  
@SubUl+MenuName+@Subli+         
(SELECT @SubliLink+ISNULL(pSubOfSubPage.PageName,'#')+'">' +subOfSub.MenuNameHindi+'</a></li>' from cmsPublicMenu subOfSub  
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId      
  
 where ParentId=SubMenu.MenuId            
order by  Priority asc,ParentId, MenuId                         
FOR XML PATH('')) +'</ul></li>'      
  
  
  
) else   
  
@SubliLink+ISNULL(pSubPage.PageName,'#')+'">' +MainMenu.MenuNameHindi+'</a></li>'  end)  
  
  
from cmsPublicMenu SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId      
where ParentId=MainMenu.MenuId             
  
  
  
order by  Priority asc,ParentId, MenuId                         
FOR XML PATH('')) +'</ul></li>'            
            
else @li+ISNULL(pMainPage.PageName,'#')+'">' +MainMenu.MenuNameHindi+'</a></li>'   end  as MenuName            
            
from cmsPublicMenu MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId      
      
      
where MainMenu.ParentId is null     and MainMenu.Status='P'        
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                       
  FOR XML PATH('')            
            
),'')      

         
Select @Menulist MenuList,@MenulistHindi MenulistHindi
GO
/****** Object:  StoredProcedure [dbo].[GetPublicMenuAdmin]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetPublicMenuAdmin]                      
@MenuId int =null ,            
@UserId varchar(50)=null,              
@ActionName varchar(50)=null   ,                
@SearchContent varchar(100)=null ,                 
@Status varchar(100)=null                  
                      
As                      
begin                      
Select t.MenuId, t.MenuName,    p.PageName ,  t.ParentId,p.PageId,t.LinkType,     
 t.MenuNameHindi,    t.Priority,     t.Path,t.Target, 
t.Status,s.StatusName    ,                   
(case when (Select r.AllowDelete from ApplicationUser as l               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-danger"><a onclick=Delete(' +Convert(varchar(10),t.MenuId) + ')>Delete</a></li>') else '' end) as DeletePermission,              
              
(case when (Select r.AllowUpdate from ApplicationUser as l               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<li class="btn btn-primary"> <a href=/Admin/PublicMenuCreate?MenuId=' + Convert(varchar(10),t.MenuId) + ' >Edit</a></li>') else '' end) as EditPermission             
              
     ,(case when (Select r.AllowPublish from ApplicationUser as l             
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)              
inner join cmsApplicationDetails d on r.MenuId=d.MenuId             
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-' + (case when t.Status = 'P' then 'success' else 'warning' end) + '"><a onclick=Publish(' +  Convert(varchar(10),t.MenuId) + ',"' +t.Status + '")>' + s.StatusName + '</a></li>') else '' end) as PublishPermission          
        
from cmsPublicMenu t                      
left join cmsPublicMenuPublish c on t.MenuId=c.MenuId                      
left join cmsPages p on t.PageId=p.PageId                      
left join cmsStatus s on t.Status=s.Prefix                      
                      
where   
((t.MenuId=@MenuId and @MenuId is not null) or @MenuId is null)  and  
((t.Status=@Status and @Status is not null) or @Status is null)  and  
((t.MenuName like '%'+@SearchContent+'%'   and @SearchContent is not null) or @SearchContent is null)                      
                      
order by t.Priority asc                      
end 
GO
/****** Object:  StoredProcedure [dbo].[GetPublicMenuAuditTrail]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetPublicMenuAuditTrail]                          
@SearchContent varchar(100)=null ,                     
@Status varchar(100)=null                      
                          
As                          
begin                          
Select t.MenuId, t.MenuName,    p.PageName ,  t.ParentId,p.PageId,t.LinkType,      
t.ActionBy,t.ActionName,t.ActionOn,     
 t.MenuNameHindi,    t.Priority,     t.Path,t.Target,     
                      
                 
  '<li class="btn btn-primary"> <a href=/Admin/PublicMenuCreate?MenuId=' + Convert(varchar(10),t.MenuId) + ' >View/Clone</a></li>'  as EditPermission                 
            
from cmsPublicMenu_History t                                                  
left join cmsPages p on t.PageId=p.PageId                            
                          
where           
((t.MenuName like '%'+@SearchContent+'%'   and @SearchContent is not null) or @SearchContent is null)                          
                          
order by case when t.UpdatedOn is null then t.CreatedOn else t.UpdatedOn end desc                          
end 
GO
/****** Object:  StoredProcedure [dbo].[GetPublicMenuCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE Procedure [dbo].[GetPublicMenuCreateButton]  -- GetPublicMenuCreateButton 'Admin','GetTenderCategory'    
@UserId varchar(50)=null,    
@ActionName varchar(50)=null    
As  



Select 
(Select count(*) from cmsPublicMenu) AllMenu,
(Select count(*) from cmsPublicMenu where Status='P') AllPublish,
(Select count(*) from cmsPublicMenu Where Status='D') PendingForPublish,

(case when (Select r.AllowInsert from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName='GetPublicMenuCreate')=1 then   
  
('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/PublicMenuCreate">Add New Menu</a></div>') else '' end) as CreatePermission    
    
GO
/****** Object:  StoredProcedure [dbo].[GetPublicMenuLinkCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetPublicMenuLinkCreateButton]  -- GetPublicMenuCreateButton 'Admin','GetTenderCategory'  
@UserId varchar(50)=null,  
@ActionName varchar(50)=null  
As
Select (case when (Select r.AllowInsert from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName='GetPublicMenu')=1 then 

('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/PublicMenuLink">Add Link Menu</a></div>') else '' end) as DeletePermission  
  
GO
/****** Object:  StoredProcedure [dbo].[GetSectionsByAdmin]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
CREATE procedure [dbo].[GetSectionsByAdmin]            
@SectionName varchar(50)  =null  ,      
@SectionId varchar(50)  =null ,       
@PageId varchar(50)  =null   ,
@UserId varchar(50)=null,  
@ActionName varchar(50)=null        
as            
Select 
  
(case when (Select r.AllowDelete from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),SectionId) + ')>Delete</a>') else '' end) as DeletePermission,  
  
(case when (Select r.AllowUpdate from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Section?SectionId=' + Convert(varchar(10),SectionId) + ' >Edit</a>') else '' end) as EditPermission,  
  
(case when (Select r.AllowPublish from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.Status = 'P' then 'success' else 'warning' end) + '" onclick=Publish(' +  Convert(varchar(10),SectionId) + ',"' +p.Status + '")>' + s.StatusName + '</a>') else '' end) as PublishPermission,
  

SectionId      
      ,PageId      
      ,SectionContent  ,    p.CreatedOn,p.UpdatedOn    
      ,SectionName          
      ,SectionTitle    ,s.StatusName      
      ,p.Status from cmsSection p      
inner join cmsStatus s on p.Status=s.Prefix         
Where      
((SectionName=@SectionName  and @SectionName is not null) or @SectionName is null) and      
((PageId=@PageId  and @PageId is not null) or @PageId is null) and      
((SectionId=@SectionId  and @SectionId is not null) or @SectionId is null) order by SectionId desc      
GO
/****** Object:  StoredProcedure [dbo].[GetSiteMap]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetSiteMap]   -- GetMainSite null,'Empty'                               
                             
as                            
  declare @Menulist nvarchar(max)                                             
declare @MenulistHindi nvarchar(max)                                             
                                       
declare @Ul nvarchar(max)  ,@li nvarchar(max)       ,@Subli nvarchar(max)  ,            
@SubUl nvarchar(max)  ,@SubliLink nvarchar(max) ,@SubMegaMenuLI nvarchar(max)  ,            
@SubMegaMenuHtmlUl nvarchar(max)                                                  
            
                                          
      Set @li='<li><a href="'                                    
      Set @SubUl=' <li><a href="#">'                                    
      Set @Subli='</a><ul>'                                  
      Set @SubliLink=' <li><a href="'                                  
      Set @SubMegaMenuLI=' <li><a href="#">'                                  
      Set @SubMegaMenuHtmlUl='</a><ul>'                                  
                                     
     BEGIN --English Menu              
SELECT                                                                                   
@Menulist=isnull((                                  
                                  
SELECT                                    
case when (select COUNT(*) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>0 then                              
                                  
(case when (Select count(parentId) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>8 then       
@SubMegaMenuLI+ MainMenu.MenuName+'+'+@SubMegaMenuHtmlUl else @SubUl+ MainMenu.MenuName+'+'+@Subli end)+                         
(                        
                        
SELECT                         
(case when (select COUNT(*) from cmsPublicMenuPublish subSub where ParentId=SubMenu.MenuId and Status='P')>0 then                          
(                        
                        
@SubUl+SubMenu.MenuName+' +'+@Subli+                               
(SELECT @SubliLink+     
(case when subOfSub.LinkType='Url' then ISNULL(subOfSub.Path,'#') else  ISNULL(pSubOfSubPage.PageName,'#') end)    
+'" target="'+ISNULL(subOfSub.Target,'')+'" >' +subOfSub.MenuName+'</a></li>' from cmsPublicMenuPublish subOfSub                        
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId                            
                        
 where ParentId=SubMenu.MenuId        and subOfSub.Status='P'                            
order by  Priority asc,ParentId, MenuId                                               
FOR XML PATH('')) +'</ul></li>'                            
                        
                        
                        
) else                         
                        
@SubliLink+(case when SubMenu.LinkType='Url' then ISNULL(SubMenu.Path,'#') else ISNULL(pSubPage.PageName,'#') end)    
+'" target="'+ISNULL(SubMenu.Target,'')+'">' +SubMenu.MenuName+'</a></li>'  end)                        
                        
                        
from cmsPublicMenuPublish SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId                            
where ParentId=MainMenu.MenuId   and SubMenu.Status='P'                                  
                        
                        
                        
order by  Priority asc,ParentId, MenuId                                               
FOR XML PATH('')) +'</ul></li>'                                  
                                  
else @li+(case when MainMenu.LinkType='Url' then ISNULL(MainMenu.Path,'#') else ISNULL(pMainPage.PageName,'#') end)    
    
+'" target="'+ISNULL(MainMenu.Target,'')+'">' +MainMenu.MenuName+'</a></li>'   end  as MenuName                                  
                                  
from cmsPublicMenuPublish MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId                            
                            
            
where MainMenu.ParentId is null     and MainMenu.Status='P'                              
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                                      
  FOR XML PATH('')                                  
                                  
),'')         
     END                 
              
  BEGIN -- HINDI MENU              
SELECT                                                                                   
@MenulistHindi=isnull((                                                            
SELECT                                    
case when (select COUNT(*) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>0 then                              
                        
                             
                                  
(case when (Select count(parentId) from cmsPublicMenuPublish where ParentId=MainMenu.MenuId and Status='P')>8 then       
@SubMegaMenuLI+ MainMenu.MenuNameHindi+'+'+@SubMegaMenuHtmlUl else @SubUl+ MainMenu.MenuNameHindi+'+'+@Subli end)+                         
(                        
                        
SELECT                         
(case when (select COUNT(*) from cmsPublicMenuPublish subSub where ParentId=SubMenu.MenuId and Status='P')>0 then                          
(                        
                        
@SubUl+SubMenu.MenuNameHindi+' +'+@Subli+                               
(SELECT @SubliLink+(case when subOfSub.LinkType='Url' then ISNULL(subOfSub.Path,'#') else  ISNULL(pSubOfSubPage.PageName,'#') end)    
+'" target="'+ISNULL(subOfSub.Target,'')+'">' +subOfSub.MenuNameHindi+'</a></li>' from cmsPublicMenuPublish subOfSub                        
 left join cmsPages pSubOfSubPage on subOfSub.PageId=pSubOfSubPage.PageId                            
                        
 where ParentId=SubMenu.MenuId    and subOfSub.Status='P'                                
order by  Priority asc,ParentId, MenuId                                               
FOR XML PATH('')) +'</ul></li>'                            
                   
                        
                        
) else                         
                        
@SubliLink+(case when SubMenu.LinkType='Url' then ISNULL(SubMenu.Path,'#') else  ISNULL(pSubPage.PageName,'#') End)    
    
+'" target="'+ISNULL(SubMenu.Target,'')+'">' +SubMenu.MenuNameHindi+'</a></li>'  end)                        
                        
                        
from cmsPublicMenuPublish SubMenu left join cmsPages pSubPage on SubMenu.PageId=pSubPage.PageId                            
where ParentId=MainMenu.MenuId        and SubMenu.Status='P'                             
                        
                        
                        
order by  Priority asc,ParentId, MenuId                                               
FOR XML PATH('')) +'</ul></li>'                           
                                  
else @li+(case when MainMenu.LinkType='Url' then ISNULL(MainMenu.Path,'#') else  ISNULL(pMainPage.PageName,'#') End)    
+'" target="'+ISNULL(MainMenu.Target,'')+'">' +MainMenu.MenuNameHindi+'</a></li>'   end  as MenuName                                  
                                  
from cmsPublicMenuPublish MainMenu left join cmsPages pMainPage on MainMenu.PageId=pMainPage.PageId                            
                            
                            
where MainMenu.ParentId is null     and MainMenu.Status='P'                              
        order by  Priority asc,MainMenu.ParentId, MainMenu.MenuId                                             
  FOR XML PATH('')                                  
                                  
),'')                            
        END              
              
  
            Select @Menulist Menulist,@MenulistHindi MenulistHindi  
GO
/****** Object:  StoredProcedure [dbo].[GetTender]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                           
CREATE Procedure [dbo].[GetTender]  -- GetTender 16                            
@TenderId int =null,                            
@CatId int =null   ,                        
@UserId varchar(50)=null,                        
@ActionName varchar(50)=null                         
                            
As                            
begin                            
select  tenderId,tenderTitle,tenderRefNo,productCategory,subCategory,tenderValueType ,         
tenderValue,emd,documentCost,tenderType,biddingType,limited,location,         
workDescription,preQualification,format1,format2,format3,format4,format5,depName,tn.CreatedBy,tn.CIPAddress,              
tc.CategoryName,tn.Status,                  
      
ISNULL(Format(PublishedDate,'dd-MMM-yyyy'),'') PublishedDate,        
ISNULL(Format(createDate,'dd-MMM-yyyy'),'') createDate,        
ISNULL(Format(ExpiryDate,'dd-MMM-yyyy'),'') ExpiryDate,      
      
ISNULL(Format(CONVERT(date,firstAnnouncementDate,103),'dd-MM-yyyy'),'') firstAnnouncementDate,      
ISNULL(Format(CONVERT(date,lastDateOfCollection,103),'dd-MM-yyyy'),'') lastDateOfCollection,      
ISNULL(Format(CONVERT(date,lastDateForSubmission,103),'dd-MM-yyyy'),'') lastDateForSubmission,      
ISNULL(Format(CONVERT(date,openingDate,103),'dd-MM-yyyy'),'') openingDate,      
ISNULL(Format(CONVERT(date,preBidMeet,103),'dd-MM-yyyy'),'') preBidMeet,      
ISNULL(Format(CONVERT(date,recievingDate,103),'dd-MM-yyyy'),'') recievingDate,      
ISNULL(Format(CONVERT(date,LastDateOfEvaluation,103),'dd-MM-yyyy'),'') LastDateOfEvaluation,      
       
lastDateOfCollection lastDateOfCollectionWithTime,      
lastDateForSubmission lastDateForSubmissionWithTime,      
openingDate openingDateWithTime,      
preBidMeet preBidMeetWithTime,      
recievingDate recievingDateWithTime,      
 UnderEvaluation  ,    
         
(case when (Select r.AllowInsert from ApplicationUser as l                         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-success"><a href=/Admin/TenderUploadDocs?TenderId=' + Convert(varchar(10),tenderId) + '>Upload Document</a></li>') else '' end) as UploadDocument,               
  
    
      
        
         
              
(case when (Select r.AllowDelete from ApplicationUser as l                         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-danger"><a onclick=Delete(' +Convert(varchar(10),tenderId) + ')>Delete</a></li>') else '' end) as DeletePermission,                        
                        
(case when (Select r.AllowUpdate from ApplicationUser as l                         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<li class="btn btn-primary"> <a href=/Admin/Tender?TenderId=' + Convert(varchar(10),tenderId) + ' >Edit</a></li>') else '' end) as EditPermission,                        
                        
(case when (Select r.AllowPublish from ApplicationUser as l                         
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                          
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                         
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-' + (case when tn.Status = 'P' then 'success' else 'warning' end) + '"><a onclick=Publish(' +  Convert(varchar(10),tenderId) + ',"' +tn.Status + '")>' + s.StatusName + '</a></li>') else '' end) as PublishPermission                      
                            
from cmsTenders tn       
left join cmsTenderCategory tc on tn.productCategory=tc.CategoryId                            
left join cmsStatus s on tn.Status=s.Prefix                             
where                             
((tn.tenderId=@TenderId and @TenderId is not null) or @TenderId is null) and                            
((tn.productCategory=@CatId and @CatId is not null) or @CatId is null)   order by tenderId desc                          
end 
GO
/****** Object:  StoredProcedure [dbo].[GetTenderCategory]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetTenderCategory]  -- GetTenderCategory null,'Admin','GetTenderCategory'  
@CategoryId int =null  ,  
@UserId varchar(50)=null,  
@ActionName varchar(50)=null  
As    
begin    
Select t.CategoryId, t.CategoryName,    
t.CreatedBy,t.CIPAddress,format(t.CreatedOn,'dd-MMM-yyyy') CreatedOn,    
t.Status,s.StatusName   ,  
  
(case when (Select r.AllowDelete from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-danger"><a onclick=Delete(' + Convert(varchar(10),t.CategoryId) + ')>Delete</a></li>') else '' end) as DeletePermission,  
  
(case when (Select r.AllowUpdate from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-primary"> <a id=' +  Convert(varchar(10),t.CategoryId)+ ' title="' +  t.CategoryName + '" href="TenderCategoryAdd?CategoryId=' + Convert(varchar(10),t.CategoryId) + '" >Edit</a></li>') else '' end) as EditPermission  
  
  
from cmsTenderCategory t    
left join cmsTenderCategoryPublish c on t.CategoryId=c.CategoryId    
left join cmsStatus s on t.Status=s.Prefix    
    
where ((t.CategoryId=@CategoryId and @CategoryId is not null) or @CategoryId is null)    
    
order by t.CategoryId desc    
end    
    
    
GO
/****** Object:  StoredProcedure [dbo].[GetTenderCategoryCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetTenderCategoryCreateButton]  -- GetTenderCategoryCreateButton 'Admin','GetTenderCategory'  
@UserId varchar(50)=null,  
@ActionName varchar(50)=null  
As
Select (case when (Select r.AllowInsert from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName='GetTenderCategory')=1 then 

('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/TenderCategoryAdd">Add New Category</a></div>') else '' end) as DeletePermission  
  
GO
/****** Object:  StoredProcedure [dbo].[GetTenderCategoryList]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetTenderCategoryList]
as
Select CategoryId as Id, CategoryName as Value ,CategoryName as Text from cmsTenderCategory
GO
/****** Object:  StoredProcedure [dbo].[GetTenderCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetTenderCreateButton]  -- GetTenderCreateButton 'Admin','GetTender'  
@UserId varchar(50)=null,  
@ActionName varchar(50)=null  
As
Select (case when (Select r.AllowInsert from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName='GetTender')=1 then 

('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Tender">Add New tender</a></div>') else '' end) as DeletePermission  
  
GO
/****** Object:  StoredProcedure [dbo].[GetTenderDocs]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                 
CREATE Procedure [dbo].[GetTenderDocs]  -- GetTenderDocs 3                  
@TenderId int =null,                  
@tenderDocsId int =null                
             
                  
As                  
begin                  
select  tenderDocsId,tenderId,corrigendumTitle,corrName,format2,submissionDate  
      ,tenderDocument,tenderDocument1,tenderDocument2,tenderDocument3,tenderDocument4  
      ,linkName,linkName1,linkName2,linkName3,linkName4,createDate,modifyDate,  
  Status              
            
              
from cmsTenderDocs                      
  
where                   
((tenderId=@TenderId and @TenderId is not null) or @TenderId is null) and                  
((tenderDocsId=@tenderDocsId and @tenderDocsId is not null) or @tenderDocsId is null)   order by tenderId desc                
end 
GO
/****** Object:  StoredProcedure [dbo].[GetTenderForPublic]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                            
CREATE Procedure [dbo].[GetTenderForPublic]  -- GetTenderForPublic 26                            
@TenderId int =null,                            
@CatId int =null                               
                            
As                            
begin                            
Select tenderId,tenderTitle,tenderRefNo,productCategory,subCategory,tenderValueType ,         
 UnderEvaluation,LastDateOfEvaluation  ,             
Format(PublishedDate,'dd-MMM-yyyy') PublishedDate,            
Format(createDate,'dd-MMM-yyyy') createDate    ,            
Format(ExpiryDate,'dd-MMM-yyyy') ExpiryDate                           
      ,tenderValue,emd,documentCost,tenderType,biddingType,limited,location ,      
                     lastDateForSubmission,firstAnnouncementDate
      ,lastDateOfCollection,openingDate,workDescription,preQualification,preBidMeet                  
      ,format1,format2,format3,format4,format5,depName,recievingDate,tn.CreatedBy,tn.CIPAddress,                  
       tc.CategoryName,tn.Status,productCategory ,tc.CategoryName ,               
        
(Select  '<div class="row">     
<div class="col-md-12">        
<a href="/Upload/Tender/'+CONVERT(varchar, TenderId)+'/'+tenderDocument+'" target="_blank">'+corrigendumTitle+'</a></div></div><div style="border: 0;margin-top: 3px;margin-bottom: 3px;border-top: 1px solid rgba(0,0,0,.1)"></div>'         
 from cmsTenderDocs where tenderId=tn.tenderId         
 order by tenderDocsId for XML Path('')        
) as Download        
        
        
        
                            
from cmsTenderPublish tn                            
inner join cmsTenderCategory tc on tn.productCategory=tc.CategoryId                            
where                 
tn.Status='P' and                
CONVERT(date,tn.firstAnnouncementDate,103)<=CONVERT(date,getdate(),103)    and                   
CONVERT(date,tn.lastDateForSubmission,103)>=CONVERT(date,getdate(),103)    and                   
((tn.TenderId=@TenderId and @TenderId is not null) or @TenderId is null) and                            
((tn.productCategory=@CatId and @CatId is not null) or @CatId is null)   order by TenderId desc                          
end   
GO
/****** Object:  StoredProcedure [dbo].[GetTenderForPublicForAchieved]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                          
CREATE Procedure [dbo].[GetTenderForPublicForAchieved]  -- GetTenderForPublicForAchieved 26                          
As                          
begin                          
Select tenderId,tenderTitle,tenderRefNo,productCategory,subCategory,tenderValueType ,              
Format(PublishedDate,'dd-MMM-yyyy') PublishedDate,          
Format(createDate,'dd-MMM-yyyy') createDate    ,          
Format(ExpiryDate,'dd-MMM-yyyy') ExpiryDate              
      ,tenderValue,emd,documentCost,tenderType,biddingType,limited,location,      
   firstAnnouncementDate         ,  UnderEvaluation,LastDateOfEvaluation         
      ,lastDateOfCollection,lastDateForSubmission,openingDate,workDescription,preQualification,preBidMeet                
      ,format1,format2,format3,format4,format5,depName,recievingDate,tn.CreatedBy,tn.CIPAddress,                
       tc.CategoryName,tn.Status,productCategory ,tc.CategoryName ,             
      
(Select  '<div class="row">      
<div class="col-md-12">      
<a href="/Upload/Tender/'+CONVERT(varchar, TenderId)+'/'+tenderDocument+'" target="_blank">'+corrigendumTitle+'</a></div></div><div style="border: 0;margin-top: 3px;margin-bottom: 3px;border-top: 1px solid rgba(0,0,0,.1)"></div>'       
 from cmsTenderDocs where tenderId=tn.tenderId       
 order by tenderDocsId for XML Path('')      
) as Download      
      
      
      
                          
from cmsTenderPublish tn                          
inner join cmsTenderCategory tc on tn.productCategory=tc.CategoryId                          
where               
tn.Status='P'        
and CONVERT(date,tn.lastDateForSubmission,103)<=CONVERT(date,getdate(),103)                     
and ((CONVERT(date,tn.LastDateOfEvaluation,103)<=CONVERT(date,getdate(),103) and tn.LastDateOfEvaluation is not null) or tn.LastDateOfEvaluation is null )  
  
  order by TenderId desc                        
end 
GO
/****** Object:  StoredProcedure [dbo].[GetTenderForPublicForEvaluation]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                        
CREATE Procedure [dbo].[GetTenderForPublicForEvaluation]  -- GetTenderForPublicForEvaluation 26                        
As                        
begin                        
Select tenderId,tenderTitle,tenderRefNo,productCategory,subCategory,tenderValueType ,            
Format(PublishedDate,'dd-MMM-yyyy') PublishedDate,        
Format(createDate,'dd-MMM-yyyy') createDate    ,        
Format(ExpiryDate,'dd-MMM-yyyy') ExpiryDate            
      ,tenderValue,emd,documentCost,tenderType,biddingType,limited,location,    
   firstAnnouncementDate         ,  UnderEvaluation,LastDateOfEvaluation       
      ,lastDateOfCollection,lastDateForSubmission,openingDate,workDescription,preQualification,preBidMeet              
      ,format1,format2,format3,format4,format5,depName,recievingDate,tn.CreatedBy,tn.CIPAddress,              
       tc.CategoryName,tn.Status,productCategory ,tc.CategoryName ,           
    
(Select  '<div class="row">
<div class="col-md-12">    
<a href="/Upload/Tender/'+CONVERT(varchar, TenderId)+'/'+tenderDocument+'" target="_blank">'+corrigendumTitle +'</a></div></div><div style="border: 0;margin-top: 3px;margin-bottom: 3px;border-top: 1px solid rgba(0,0,0,.1)"></div>'     
 from cmsTenderDocs where tenderId=tn.tenderId     
 order by tenderDocsId for XML Path('')    
) as Download    
    
    
    
                        
from cmsTenderPublish tn                        
inner join cmsTenderCategory tc on tn.productCategory=tc.CategoryId                        
where             
tn.Status='P' and UnderEvaluation='Yes'   
 and CONVERT(date,tn.lastDateForSubmission,103)<=CONVERT(date,getdate(),103)                 
 and CONVERT(date,tn.LastDateOfEvaluation,103)>=CONVERT(date,getdate(),103)                 
  order by TenderId desc                      
end 
GO
/****** Object:  StoredProcedure [dbo].[GetTheme]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE procedure [dbo].[GetTheme]        -- GetTheme 'Superadmin','ThemeManage'      
@UserId varchar(50)=null,                              
@ActionName varchar(50)=null     
as              
Select    
(case when (Select r.AllowDelete from ApplicationUser as l                               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-danger" onclick=Delete(' +Convert(varchar(10),MainSiteId) + ')>Delete</a>') else '' end) as DeletePermission,                              
                              
(case when (Select r.AllowUpdate from ApplicationUser as l                               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<a class="btn btn-primary" href=/Admin/Theme?MainSiteId=' + Convert(varchar(10),MainSiteId) + ' >Edit</a>') else '' end) as EditPermission,                              
                              
(case when (Select r.AllowPublish from ApplicationUser as l                               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.Status = 'I' then 'success' else 'warning' end) + ' onclick=Publish(' +  Convert(varchar(10),MainSiteId) + ',"' +p.Status + '")>' + s.StatusName 
  
+ '</a>') else '' end) as InstallPermission ,   
   
  (case when (Select r.AllowPublish from ApplicationUser as l                               
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)                                
inner join cmsApplicationDetails d on r.MenuId=d.MenuId                               
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<a class="btn btn-' + (case when p.StatusPublish = 'P' then 'success' else 'warning' end) + '" onclick=Publish(' +  Convert(varchar(10),MainSiteId) + ',"' +p.StatusPublish + '")>' +
pp.StatusName+ '</a>') else '' end) as PublishPermission ,    
  
 MainSiteId            
      ,ThemeName            
        ,s.StatusName        
      ,p.Status from cmsMainSite p        
inner join cmsStatus s on p.Status=s.Prefix           
inner join cmsStatus pp on p.StatusPublish=pp.Prefix           
      
GO
/****** Object:  StoredProcedure [dbo].[GetThemeCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE Procedure [dbo].[GetThemeCreateButton]  -- GetThemeCreateButton 'Admin','GetTender'    
@UserId varchar(50)=null,    
@ActionName varchar(50)=null    
As  
Select (case when (Select r.AllowInsert from ApplicationUser as l     
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)      
inner join cmsApplicationDetails d on r.MenuId=d.MenuId     
where userid=@UserId and r.Status=1   and ActionName='GetTender')=1 then   
  
('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Theme">Add New Theme</a></div>') else '' end) as DeletePermission    
    
GO
/****** Object:  StoredProcedure [dbo].[GetUserAll]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetUserAll]    --  GetUserAll  null,'Admin',null,'GetUser'        
@Id nvarchar(100)=null,              
@UserId nvarchar(100)=null,              
@EmailOrMobile nvarchar(100)=null      ,        
@ActionName varchar(50)=null          
              
as              
select        
        
          
(case when (Select r.AllowDelete from ApplicationUser as l           
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then ('<li class="btn btn-danger"><a onclick=Delete(' +Convert(varchar(10),id) + ')>Delete</a></li>') else '' end) as DeletePermission,          
          
(case when (Select r.AllowUpdate from ApplicationUser as l           
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then  ('<li class="btn btn-primary"> <a href=/Admin/Users?id=' + Convert(varchar(10),Id) + ' >Edit</a></li>') else '' end) as EditPermission,          
          
(case when (Select r.AllowPublish from ApplicationUser as l           
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)            
inner join cmsApplicationDetails d on r.MenuId=d.MenuId           
where userid=@UserId and r.Status=1   and ActionName=@ActionName)=1 then         
        
('<li class="btn btn-' + (case when a.isBlock=1 then 'success' else 'warning' end) + '"><a onclick=Block(' +  Convert(varchar(10),Id) + ',' +(case when isBlock=1 then '1' else '0' end) + ')>' + (case when a.isBlock=1 then 'Unblock' else 'Block' end) + '</
  
    
      
a></li>')         
else 's' end) as BlockPermission        
  ,        
        
 [Id]              
      ,[UserId]              
      --,[Password]              
    ,a.DepartmentId  DepartmentIds     
      ,a.RoleId   Role        
        
      ,[EmployeeId]              
      ,[MobileNo]              
      ,[UserName]              
      ,[Email]              
      ,[OfficeType]              
      ,[OfficeId]              
      ,Format(a.CreatedOn,'dd-MMM-yyyy') CreatedOn              
      ,a.CreatedBy              
      ,[LastUpdatedOn]              
      ,[LastUpdatedBy]              
      ,[LastLoginDateTime]              
      ,[LastLoginIPAddress]              
      ,[CurrentIPAddress]              
      ,[CurrentLoginDateTime]  ,            
   r.RoleTitle RoleName,       
  -- d.DepartmentName   ,    
   (case when isBlock is null then 0 else 1 end) as isBlock  ,            
   (case when isBlock is null then 'Block' else 'Unblock' end) as BlockStatus              
                 
                 
   from ApplicationUser     a          
   left join cmsRole r on a.Role=r.Role       
 --  left join cmsDepartment d on a.DepartmentId=d.DepartmentId       
where     userId!='Superadmin' and          
((Id=@Id and @Id is not null) or @Id is null) and              
--((UserId=@UserId and @UserId is not null) or @UserId is null) and              
((MobileNo=@EmailOrMobile or Email=@EmailOrMobile and @EmailOrMobile is not null) or @EmailOrMobile is null)   
GO
/****** Object:  StoredProcedure [dbo].[GetUserMenu]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetUserMenu]  -- GetUserMenu 'C'  
@Role varchar(10)    
As    
    
Select ISNULL((Select d.PageName from cmsApplicationRights r left join cmsApplicationDetails d on  r.MenuId=d.MenuId    
where r.Role=@Role  and r.Status=1  
for XML path('')),'')
GO
/****** Object:  StoredProcedure [dbo].[GetUserRights]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetUserRights]     -- GetUserRights   'A'
@Role varchar(10) =null        
        
As        
begin        
Select t.MenuId, t.MenuName,    t.PageName ,    t.ParentId,
t.Status,r.AllowDelete,r.AllowUpdate,r.Role  ,r.Status
from cmsApplicationDetails t
--left join cmsApplicationDetails tt  on t.ParentId=tt.ParentId

left join cmsApplicationRights r  on r.MenuId=t.MenuId


where r.Role=@Role

--((r.Role=@Role and @Role is not null) or @Role is null)        
order by t.MenuId desc        
end        
GO
/****** Object:  StoredProcedure [dbo].[GeUsersManageCreateButton]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[GeUsersManageCreateButton]  -- UsersManage 'Admin','SectionManage'  
@UserId varchar(50)=null,  
@ActionName varchar(50)=null  
As
Select (case when (Select r.AllowInsert from ApplicationUser as l   
inner join cmsApplicationRights r on l.Role=convert(varchar(10), r.Role)    
inner join cmsApplicationDetails d on r.MenuId=d.MenuId   
where userid=@UserId and r.Status=1   and ActionName='GetUser')=1 then 

('<div class="buttonstyle"><a class="btn btn-success" href="/Admin/Users">Add New User</a></div>') else '' end) as DeletePermission  
  
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateCareer]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE Procedure [dbo].[InsertUpdateCareer]  
@CareerId bigint =null,  
@depName varchar(100) =null,  
@vacancyTitle nvarchar(1000) =null,  
@firstAnnouncementDate varchar(50) =null,  
@lastDateOfCollection varchar(50) =null,  
@vacancyDocument varchar(100) =null,  
@vacancyRefNo varchar(200) =null,  
@CreatedBy varchar(50)=null,  
@CIPAddress varchar(50)=null  
  
AS  
begin  
BEGIN TRAN  
BEGIN TRY  
if exists(select * from cmsCareer where CareerId=@CareerId)  
begin  

  
Update cmsCareer set  
vacancyRefNo=@vacancyRefNo,  
depName=@depName,  
firstAnnouncementDate=@firstAnnouncementDate,  
vacancyTitle=@vacancyTitle,  
lastDateOfCollection=@lastDateOfCollection,  
vacancyDocument=@vacancyDocument,  
Status='D',  
UIPAddress=@CIPAddress,  
UpdatedBy=@CreatedBy,  
modifyDate=GETDATE()  
Where CareerId=@CareerId  
  
select 't' ResultStatus , 'Data Updated Successfull.' ResultMessage ,@CareerId as Id  

end  
else  
Insert Into   
cmsCareer(depName,vacancyTitle,firstAnnouncementDate,lastDateOfCollection,vacancyRefNo,vacancyDocument,Status, createDate, CreatedBy,CIPAddress)  
   values(@depName,@vacancyTitle,@firstAnnouncementDate,@lastDateOfCollection,@vacancyRefNo,@vacancyDocument,'D',GETDATE(),@CreatedBy,@CIPAddress)  
  
select 't' ResultStatus , 'Career Created Successfull.' ResultMessage ,@@IDENTITY Id  
  
COMMIT TRAN  
END TRY  
BEGIN CATCH  
select 'f' ResultStatus ,ERROR_MESSAGE() ResultMessage  
END CATCH  
end
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateCareerPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
       
            
CREATE Procedure [dbo].[InsertUpdateCareerPublish]              
@CareerId nvarchar(100) ,              
@Status nvarchar(10),              
@CreatedBy nvarchar(100) ,              
@CIPAddress nvarchar(100)               
              
As              
begin              
Begin Tran              
begin try              
if not exists(select * from cmsCareerPublish where CareerId=@CareerId)            
begin            
Insert into cmsCareerPublish(
       CareerId
      ,nameOfOrganization
      ,typeOfOrganization
      ,vacancyTitle
      ,vacancyRefNo
      ,productCategory
      ,subCategory
      ,vacancyValueType
      ,vacancyValue
      ,emd
      ,documentCost
      ,vacancyType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,vacancyDocument
      ,vacancyDocument1
      ,vacancyDocument2
      ,vacancyDocument3
      ,vacancyDocument4
      ,vacancyDocument5
      ,vacancyDocument6
      ,vacancyDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,vacancyDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,modifyDate
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
	    ,status
      ,CreatedBy
      ,CIPAddress
	    ,createDate
      )     
 (Select CareerId
      ,nameOfOrganization
      ,typeOfOrganization
      ,vacancyTitle
      ,vacancyRefNo
      ,productCategory
      ,subCategory
      ,vacancyValueType
      ,vacancyValue
      ,emd
      ,documentCost
      ,vacancyType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,vacancyDocument
      ,vacancyDocument1
      ,vacancyDocument2
      ,vacancyDocument3
      ,vacancyDocument4
      ,vacancyDocument5
      ,vacancyDocument6
      ,vacancyDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,vacancyDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,modifyDate
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign,
	    'P',@CreatedBy,@CIPAddress,GETDATE() from cmsCareer where CareerId=@CareerId)              
            
Update cmsCareer set             
UpdatedBy=@CreatedBy,            
modifyDate=GETDATE(),            
Status=@Status            
where CareerId=@CareerId            
            
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage              
end            
else            
begin            
if exists(select * from cmsCareerPublish where CareerId=@CareerId)            
begin            
            
Update Publish set   
     
      vacancyTitle=p.vacancyTitle
      ,vacancyRefNo=p.vacancyRefNo
      ,productCategory=p.productCategory
      ,subCategory=p.subCategory
      ,vacancyValueType=p.vacancyValueType
      ,vacancyValue=p.vacancyValue
      ,emd=p.emd
      ,documentCost=p.documentCost
      ,vacancyType=p.vacancyType
      ,biddingType=p.biddingType
      ,limited=p.limited
      ,location=p.location
      ,firstAnnouncementDate=p.firstAnnouncementDate
      ,lastDateOfCollection=p.lastDateOfCollection
      ,lastDateForSubmission=p.lastDateForSubmission
      ,openingDate=p.openingDate
      ,workDescription=p.workDescription
      ,preQualification=p.preQualification
      ,preBidMeet=p.preBidMeet
      ,vacancyDocument=p.vacancyDocument
      ,vacancyDocument1=p.vacancyDocument1
      ,vacancyDocument2=p.vacancyDocument2
      ,vacancyDocument3=p.vacancyDocument3
      ,vacancyDocument4=p.vacancyDocument4
      ,vacancyDocument5=p.vacancyDocument5
      ,vacancyDocument6=p.vacancyDocument6
      ,vacancyDocument7=p.vacancyDocument7
      ,extradoc=p.extradoc
      ,extradoc1=p.extradoc1
      ,extradoc2=p.extradoc2
      ,vacancyDocumentExtra=p.vacancyDocumentExtra
      ,hindiDocs=p.hindiDocs
      ,linkName=p.linkName
      ,linkName1=p.linkName1
      ,linkName2=p.linkName2
      ,linkName3=p.linkName3
      ,linkName4=p.linkName4
      ,format1=p.format1
      ,format2=p.format2
      ,format3=p.format3
      ,format4=p.format4
      ,format5=p.format5
      ,depName=p.depName
      ,recievingDate=p.recievingDate
      ,assignTo=p.assignTo
      ,descriptionOfAssign=p.descriptionOfAssign,
UpdatedBy=@CreatedBy,    
UIPAddress=@CIPAddress,     
modifyDate=GETDATE(),            
Status=@Status            
from cmsCareer p inner join cmsCareerPublish Publish on p.CareerId=Publish.CareerId    
where Publish.CareerId=@CareerId;            
            
            
Update cmsCareer set             
UpdatedBy=@CreatedBy,            
modifyDate=GETDATE(),            
Status=@Status            
            
where CareerId=@CareerId            
            
            
            
if(@Status ='P')            
begin            
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage             
end            
else            
begin            
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage             
end            
end            
else            
begin            
Select 'f' ResultStatus, 'Updated failed' ResultMessage              
end             
end            
commit              
end try              
begin catch              
Select 'f' ResultStatus, 'Exception Error' ResultMessage              
end catch              
              
end   
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateClone]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
           
CREATE Procedure [dbo].[InsertUpdateClone]                  
@CloneId bigint =null,  
@CloneTitle nvarchar(500) =null,  
@CloneContent nvarchar(MAX) =null,     
@CreatedBy  varchar(50)=null,              
@CIPAddress  varchar(50)=null              
              
 AS                  
 begin                
 BEGIN TRAN                  
 BEGIN TRY         
 if exists(select * from cmsClone where CloneId=@CloneId)                
  begin                
      
    Update cmsClone set       
 CloneTitle=@CloneTitle,  
 CloneContent=@CloneContent,  
  UIPAddress=@CIPAddress,      
  UpdatedBy=@CreatedBy,      
  Status='D',  
  UpdatedOn=GETDATE()      
  Where CloneId=@CloneId      
    
  select 't' ResultStatus  , 'Data Updated Successfull.' ResultMessage ,@CloneId as Id      
      
  end                
  else  
      
   Insert Into cmsClone(CloneTitle,CloneContent,Status,CreatedOn,CreatedBy,CIPAddress)                  
      values(@CloneTitle,@CloneContent,'D',GETDATE(),@CreatedBy,@CIPAddress)          
                 
     select 't' ResultStatus  , 'Clone Created Successfull.' ResultMessage ,@@IDENTITY Id                 
              
  COMMIT TRAN                  
 END TRY                  
 BEGIN CATCH                  
 select 'f' ResultStatus  ,ERROR_MESSAGE() ResultMessage                
 END CATCH   
       
    end   
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateCompainOrFeedback]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
     
CREATE Procedure [dbo].[InsertUpdateCompainOrFeedback]                  
@ComplainId int =null,      
@Name nvarchar(100) =null,   
@Email nvarchar(100) =null,   
@Address nvarchar(500) =null,   
@UploadFileName varchar(200) =null,   
@ComplainType varchar(250)=null,      
@ComplainSubject nvarchar(500) =null,      
@ComplainContent nvarchar(500)=null,      
@CreatedBy  varchar(50)=null,              
@CIPAddress  varchar(50)=null              
              
 AS                  
 begin                
 BEGIN TRAN                  
 BEGIN TRY         
 if exists(select * from cmsCompainOrFeedback where ComplainId=@ComplainId)                
  begin                
    if(@UploadFileName is null or @UploadFileName='')  
 begin  
  Update cmsCompainOrFeedback set       
 Name=@Name,      
  Email=@Email,      
  Address=@Address,      
  ComplainContent=@ComplainContent,      
  ComplainType=@ComplainType,      
  ComplainSubject=@ComplainSubject,      
  UIPAddress=@CIPAddress,      
  UpdatedBy=@CreatedBy,      
  UpdatedOn=GETDATE()      
  Where ComplainId=@ComplainId      
    
  select 't' ResultStatus  , 'Data Updated Successfull.' ResultMessage ,@ComplainId as Id      
 end  
 else  
 begin  
  Update cmsCompainOrFeedback set       
 Name=@Name,      
  Email=@Email,      
  Address=@Address,      
  UploadFileName=@UploadFileName,      
  ComplainContent=@ComplainContent,      
  ComplainType=@ComplainType,      
  ComplainSubject=@ComplainSubject,      
  UIPAddress=@CIPAddress,      
  UpdatedBy=@CreatedBy,      
  UpdatedOn=GETDATE()      
  Where ComplainId=@ComplainId      
    
  select 't' ResultStatus  , 'Data Updated Successfull.' ResultMessage ,@ComplainId as Id      
 end  
     
      
  end                
  else                
   Insert Into cmsCompainOrFeedback(Name,Email,Address,UploadFileName,ComplainContent,ComplainSubject,ComplainType,Status,CreatedOn,CreatedBy,CIPAddress)                  
      values(@Name,@Email,@Address,@UploadFileName,@ComplainContent,@ComplainSubject,@ComplainType,'S',GETDATE(),@CreatedBy,@CIPAddress)          
                 
     select 't' ResultStatus  , 'Complaint Send Successfull.' ResultMessage ,@@IDENTITY Id                 
              
  COMMIT TRAN                  
 END TRY                  
 BEGIN CATCH                  
 select 'f' ResultStatus  ,ERROR_MESSAGE() ResultMessage                
 END CATCH                  
    end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateDepartment]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[InsertUpdateDepartment]      
@DepartmentId bigint =null,      
@DepartmentType nvarchar(100) =null,      
@DepartmentName nvarchar(100) =null,      
@Status varchar(10) =null,      
@CreatedBy nvarchar(100)=null,      
@CIPAddress nvarchar(100) =null      
  as      
  begin      
  begin tran      
  begin try      
  if(@DepartmentId=0)      
  begin      
  declare @DepartmentIdsOld varchar(100)=null,  
          @DepartmentIds varchar(100)=null  
  
  Insert into cmsDepartment(DepartmentType,DepartmentName,Status,CreatedBy,CreatedOn,CIPAddress)      
                     values (@DepartmentType,@DepartmentName,'N',@CreatedBy,GETDATE(),@CIPAddress)   
    
  set @DepartmentIdsOld=(Select DepartmentId from ApplicationUser where UserId='Admin')     
  
  Set @DepartmentIds= case when @DepartmentIdsOld is null then CONVERT(varchar, @@IDENTITY) else @DepartmentIdsOld+','+CONVERT(varchar, @@IDENTITY) end  
  
  update ApplicationUser set DepartmentId=@DepartmentIds where UserId='Admin' 
  update ApplicationUser set DepartmentId=@DepartmentIds where UserId='Superadmin'  
   
  
  Select 't' ResultStatus, 'Department Added Successfull' ResultMessage     
      
  end      
  else      
  begin      
  Update cmsDepartment set       
  DepartmentType=@DepartmentType,      
  DepartmentName=@DepartmentName,      
        
  UpdatedBy=@CreatedBy,UpdatedOn=getdate(),UIPAddress=@CIPAddress      
  where DepartmentId=@DepartmentId      

  Select 't' ResultStatus, 'Department Updated Successfull' ResultMessage      
  end      
  commit      
  end try      
  begin catch      
  Select 'f' ResultStatus, 'Server Error' ResultMessage      
  end catch      
  end   
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateFaq]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
         
CREATE Procedure [dbo].[InsertUpdateFaq]                
@FaqId int =null,    
@QuestionCategory varchar(500)=null,    
@Question nvarchar(max) =null,    
@QuestionHindi nvarchar(max) =null,    
@AnswerHindi nvarchar(max)=null,    
@Answer nvarchar(max)=null,    
@CreatedBy  varchar(50)=null,            
@CIPAddress  varchar(50)=null            
            
 AS                
 begin              
 BEGIN TRAN                
 BEGIN TRY       
 if exists(select * from cmsFaq where FaqId=@FaqId)              
  begin              
    
    Update cmsFaq set     
  Answer=@Answer,    
  QuestionCategory=@QuestionCategory,    
  QuestionHindi=@QuestionHindi,
  AnswerHindi=@AnswerHindi,
  Question=@Question,    
  UIPAddress=@CIPAddress,    
  UpdatedBy=@CreatedBy,    
  Status='D',
  UpdatedOn=GETDATE()    
  Where FaqId=@FaqId    
  
  select 't' ResultStatus  , 'Data Updated Successfull.' ResultMessage ,@FaqId as Id    
    
  end              
  else              
   Insert Into cmsFaq(Answer,Question,AnswerHindi,QuestionHindi,QuestionCategory,Status,CreatedOn,AnswerDate,CreatedBy,CIPAddress)                
      values(@Answer,@Question,@AnswerHindi,@QuestionHindi,@QuestionCategory,'D',GETDATE(),GETDATE(),@CreatedBy,@CIPAddress)        
               
     select 't' ResultStatus  , 'Faq Created Successfull.' ResultMessage ,@@IDENTITY Id               
            
  COMMIT TRAN                
 END TRY                
 BEGIN CATCH                
 select 'f' ResultStatus  ,ERROR_MESSAGE() ResultMessage              
 END CATCH                
    end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateFaqPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
      
CREATE Procedure [dbo].[InsertUpdateFaqPublish]        
@FaqId nvarchar(100) ,        
@Status nvarchar(10),        
@CreatedBy nvarchar(100) ,        
@CIPAddress nvarchar(100)         
        
As        
begin        
Begin Tran        
begin try        
if not exists(select * from cmsFaqPublish where FaqId=@FaqId)      
begin      
Insert into cmsFaqPublish(FaqId,Answer,Question,AnswerHindi,QuestionHindi,QuestionCategory,Status,CreatedBy,CIPAddress,CreatedOn) 
(Select FaqId,Answer,Question,AnswerHindi,QuestionHindi,QuestionCategory,@Status,@CreatedBy,@CIPAddress,GETDATE() from cmsFaq where FaqId=@FaqId)        
      
Update cmsFaq set       
UpdatedBy=@CreatedBy,      
UpdatedOn=GETDATE(),      
Status=@Status      
where FaqId=@FaqId      
      
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage        
end      
else      
begin      
if exists(select * from cmsFaqPublish where FaqId=@FaqId)      
begin      
      
Update Publish set       
FaqId=p.FaqId,
Answer=p.Answer,
Question=p.Question,
AnswerHindi=p.AnswerHindi,
QuestionHindi=p.QuestionHindi,
QuestionCategory=p.QuestionCategory,

UpdatedBy=@CreatedBy,      
UpdatedOn=GETDATE(),      
Status=@Status      
from cmsFaq p inner join cmsFaqPublish Publish on p.FaqId=Publish.FaqId
where p.FaqId=@FaqId;      
      
      
Update cmsFaq set       
UpdatedBy=@CreatedBy,      
UpdatedOn=GETDATE(),      
Status=@Status      
      
where FaqId=@FaqId      
      
      
      
if(@Status ='P')      
begin      
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage       
end      
else      
begin      
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage       
end      
end      
else      
begin      
Select 'f' ResultStatus, 'Updated failed' ResultMessage        
end       
end      
commit        
end try        
begin catch        
Select 'f' ResultStatus, 'Exception Error' ResultMessage        
end catch        
        
end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateMainSite]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
      
CREATE Procedure [dbo].[InsertUpdateMainSite]        
@MainSiteId bigint =null,  
@ThemeName varchar(200) =null,  
@HeadTag nvarchar(MAX) =null,  
@FooterScript nvarchar(MAX) =null,  
@Header nvarchar(MAX) =null,  
@HeaderHindi nvarchar(MAX) =null,  
@BeforeManuHeader nvarchar(MAX) =null,  
@AfterManuHeader nvarchar(MAX) =null,  
@Breadcrumbs nvarchar(MAX) =null,  
@InnerPageStart nvarchar(MAX) =null,  
@InnerPageEnd nvarchar(MAX) =null,  
@ContentStart nvarchar(MAX) =null,  
@ContenEnd nvarchar(MAX) =null,  
@Footer nvarchar(MAX) =null,  
@FooterHindi nvarchar(MAX) =null,  
@Body nvarchar(MAX) =null,  
@Slider nvarchar(MAX) =null,  
@PublicMenu nvarchar(MAX) =null,  
@Pages nvarchar(MAX) =null,  
@MenuHtmlUL varchar(200) =null,  
@MenuHtmlLi varchar(200) =null,  
@SubMenuHtmlUl varchar(200) =null,  
@SubMenuHtmlLi varchar(200) =null,  
@SubMenuHtmlLiLink varchar(200) =null,  
@MegaMenuHtmlLi varchar(200) =null,  
@SubMegaMenuHtmlUl varchar(200) =null,  
@CreatedBy nvarchar(100) =null,  
@CIPAddress nvarchar(100) =null  
As        
begin        
Begin Tran        
begin try        
if not exists(select * from cmsMainSite where MainSiteId=@MainSiteId)          
begin          
Insert into cmsMainSite  
       (ThemeName,HeadTag,FooterScript,Header,HeaderHindi  
      ,BeforeManuHeader,AfterManuHeader,Breadcrumbs,InnerPageStart,InnerPageEnd,ContentStart,ContenEnd,Footer  
      ,FooterHindi,Body,Slider,PublicMenu,Pages,MenuHtmlUL,MenuHtmlLi,SubMenuHtmlUl,SubMenuHtmlLi,SubMenuHtmlLiLink  
      ,MegaMenuHtmlLi,SubMegaMenuHtmlUl,Status,StatusPublish,CreatedBy,CIPAddress,CreatedOn)   
     
   values (@ThemeName,@HeadTag,@FooterScript,@Header,@HeaderHindi,@BeforeManuHeader  
      ,@AfterManuHeader,@Breadcrumbs,@InnerPageStart,@InnerPageEnd,@ContentStart,@ContenEnd  
      ,@Footer,@FooterHindi,@Body,@Slider,@PublicMenu,@Pages,@MenuHtmlUL,@MenuHtmlLi,@SubMenuHtmlUl,@SubMenuHtmlLi  
   ,@SubMenuHtmlLiLink,@MegaMenuHtmlLi,@SubMegaMenuHtmlUl,'A','D'  
      ,@CreatedBy,@CIPAddress,GETDATE())            
     
          
Select 't' ResultStatus, 'Data Inserted Successfully.' ResultMessage            
end        
else      
begin      
if exists(select * from cmsMainSite where MainSiteId=@MainSiteId)      
begin      
      
Update cmsMainSite set      
  ThemeName=@ThemeName ,  
  HeadTag=@HeadTag ,  
  FooterScript=@FooterScript ,  
  Header=@Header ,  
  HeaderHindi=@HeaderHindi ,  
  BeforeManuHeader=@BeforeManuHeader ,  
   AfterManuHeader=@AfterManuHeader ,  
   Breadcrumbs=@Breadcrumbs ,  
   InnerPageStart=@InnerPageStart ,  
   InnerPageEnd=@InnerPageEnd ,  
   ContentStart=@ContentStart ,  
   ContenEnd=@ContenEnd,  
   Footer=@Footer ,  
   FooterHindi=@FooterHindi ,  
   Body=@Body ,  
   Slider=@Slider ,  
   PublicMenu=@PublicMenu ,  
   Pages=@Pages ,  
   MenuHtmlUL=@MenuHtmlUL ,  
   MenuHtmlLi=@MenuHtmlLi ,  
   SubMenuHtmlUl=@SubMenuHtmlUl ,  
   SubMenuHtmlLi=@SubMenuHtmlLi ,  
   SubMenuHtmlLiLink=@SubMenuHtmlLiLink ,  
   MegaMenuHtmlLi=@MegaMenuHtmlLi ,  
   SubMegaMenuHtmlUl=@SubMegaMenuHtmlUl,  
   Status='A',
   StatusPublish='D',
UpdatedBy=@CreatedBy,      
UpdatedOn=GETDATE()    
    
where MainSiteId=@MainSiteId;      
      
   Select 't' ResultStatus, 'Data Updated Successfully.' ResultMessage       
   
end      
else      
begin      
Select 'f' ResultStatus, 'Updated failed' ResultMessage        
end       
end      
commit        
end try        
begin catch        
Select 'f' ResultStatus, 'Exception Error' ResultMessage        
end catch        
        
end        
        
        
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateMainSitePublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
CREATE Procedure [dbo].[InsertUpdateMainSitePublish]      
@MainSiteId nvarchar(100) ,      
@Status nvarchar(10),      
@CreatedBy nvarchar(100) ,      
@CIPAddress nvarchar(100)       
      
As      
begin      
Begin Tran      
begin try      
if not exists(select * from cmsMainSitePublish where MainSiteId=@MainSiteId)        
begin        
Insert into cmsMainSitePublish
       (MainSiteId,ThemeName,HeadTag,FooterScript,Header,HeaderHindi
      ,BeforeManuHeader,AfterManuHeader,Breadcrumbs,InnerPageStart,InnerPageEnd,ContentStart,ContenEnd,Footer
      ,FooterHindi,Body,Slider,PublicMenu,Pages,MenuHtmlUL,MenuHtmlLi,SubMenuHtmlUl,SubMenuHtmlLi,SubMenuHtmlLiLink
      ,MegaMenuHtmlLi,SubMegaMenuHtmlUl,Status,StatusPublish,CreatedBy,CIPAddress,CreatedOn) 
	  
	  (Select MainSiteId,ThemeName,HeadTag,FooterScript,Header,HeaderHindi,BeforeManuHeader
      ,AfterManuHeader,Breadcrumbs,InnerPageStart,InnerPageEnd,ContentStart,ContenEnd
      ,Footer,FooterHindi,Body,Slider,PublicMenu,Pages,MenuHtmlUL,MenuHtmlLi,SubMenuHtmlUl,SubMenuHtmlLi
	  ,SubMenuHtmlLiLink,MegaMenuHtmlLi,SubMegaMenuHtmlUl,Status,@Status
      ,@CreatedBy,@CIPAddress,GETDATE() from cmsMainSite where MainSiteId=@MainSiteId)          
        
Update cmsMainSite set         
UpdatedBy=@CreatedBy,        
UpdatedOn=GETDATE(),        
StatusPublish=@Status        
where MainSiteId=@MainSiteId        
        
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage          
end      
else    
begin    
if exists(select * from cmsMainSitePublish where MainSiteId=@MainSiteId)    
begin    
    
Update MainSitePublish set    
  MainSiteId=t.MainSiteId,
  ThemeName=t.ThemeName ,
  HeadTag=t.HeadTag ,
  FooterScript=t.FooterScript ,
  Header=t.Header ,
  HeaderHindi=t.HeaderHindi ,
  BeforeManuHeader=t.BeforeManuHeader ,
	  AfterManuHeader=t.AfterManuHeader ,
	  Breadcrumbs=t.Breadcrumbs ,
	  InnerPageStart=t.InnerPageStart ,
	  InnerPageEnd=t.InnerPageEnd ,
	  ContentStart=t.ContentStart ,
	  ContenEnd=t.ContenEnd,
	  Footer=t.Footer ,
	  FooterHindi=t.FooterHindi ,
	  Body=t.Body ,
	  Slider=t.Slider ,
	  PublicMenu=t.PublicMenu ,
	  Pages=t.Pages ,
	  MenuHtmlUL=t.MenuHtmlUL ,
	  MenuHtmlLi=t.MenuHtmlLi ,
	  SubMenuHtmlUl=t.SubMenuHtmlUl ,
	  SubMenuHtmlLi=t.SubMenuHtmlLi ,
	  SubMenuHtmlLiLink=t.SubMenuHtmlLiLink ,
	  MegaMenuHtmlLi=t.MegaMenuHtmlLi ,
	  SubMegaMenuHtmlUl=t.SubMegaMenuHtmlUl,
	  Status=t.Status,

UpdatedBy=@CreatedBy,    
UpdatedOn=GETDATE(),    
StatusPublish=@Status    
  
from cmsMainSite t inner join cmsMainSitePublish MainSitePublish on t.MainSiteId=MainSitePublish.MainSiteId  
where MainSitePublish.MainSiteId=@MainSiteId;    
    
    
Update cmsMainSite set     
UpdatedBy=@CreatedBy,    
UpdatedOn=GETDATE(),    
StatusPublish=@Status    
    
where MainSiteId=@MainSiteId    
    
    
    
if(@Status ='P')    
begin    
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage     
end    
else    
begin    
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage     
end    
end    
else    
begin    
Select 'f' ResultStatus, 'Updated failed' ResultMessage      
end     
end    
commit      
end try      
begin catch      
Select 'f' ResultStatus, 'Exception Error' ResultMessage      
end catch      
      
end      
      
      
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateMediaGallery]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
         
CREATE Procedure [dbo].[InsertUpdateMediaGallery]                
@MediaId int =null,    
@MediaType varchar(250)=null,    
@MediaCategory varchar(50)=null,    
@FileSize varchar(50)=null,    
@Version varchar(50)=null,    
@MediaTitle nvarchar(500) =null,    
@MediaContent nvarchar(500)=null,    
@MediaTitleHindi nvarchar(500) =null,    
@MediaContentHindi nvarchar(500)=null,    
@MediaPath varchar(250)=null,    
@CreatedBy  varchar(50)=null,            
@CIPAddress  varchar(50)=null            
            
 AS                
 begin              
 BEGIN TRAN                
 BEGIN TRY       
 if exists(select * from cmsMediaGallery where MediaId=@MediaId)              
  begin              
  if(@MediaPath is null or @MediaPath ='')    
  begin    
   Update cmsMediaGallery set     
  MediaContent=@MediaContent,    
  MediaContentHindi=@MediaContentHindi,    
  MediaType=@MediaType,    
  MediaCategory=@MediaCategory,    
  MediaTitle=@MediaTitle,    
  Version=@Version,
  FileSize=@FileSize,
  MediaTitleHindi=@MediaTitleHindi,    
  UIPAddress=@CIPAddress,    
  UpdatedBy=@CreatedBy,    
  UpdatedOn=GETDATE()    
  Where MediaId=@MediaId    
  end else    
   begin     
    Update cmsMediaGallery set     
  MediaContent=@MediaContent,   
  MediaContentHindi=@MediaContentHindi,     
  MediaPath=@MediaPath,      
  MediaCategory=@MediaCategory,    
  MediaType=@MediaType,    
  MediaTitleHindi=@MediaTitleHindi,    
  MediaTitle=@MediaTitle,   
  Version=@Version,
  FileSize=@FileSize, 
  UIPAddress=@CIPAddress,    
  UpdatedBy=@CreatedBy,    
  UpdatedOn=GETDATE()    
  Where MediaId=@MediaId    
  end    
     
  select 't' ResultStatus  , 'Data Updated Successfull.' ResultMessage ,@MediaId as Id    
    
  end              
  else              
   Insert Into cmsMediaGallery(MediaContent,MediaContentHindi,MediaPath,Version,FileSize,MediaTitle,MediaTitleHindi,MediaType,MediaCategory,Status,CreatedOn,CreatedBy,CIPAddress)                
      values(@MediaContent,@MediaContentHindi,@MediaPath,@Version,@FileSize,@MediaTitle,@MediaTitleHindi,@MediaType,@MediaCategory,'D',GETDATE(),@CreatedBy,@CIPAddress)        
               
     select 't' ResultStatus  , 'Medial  Uploaded Successfull.' ResultMessage ,@@IDENTITY Id               
            
  COMMIT TRAN                
 END TRY                
 BEGIN CATCH                
 select 'f' ResultStatus  ,ERROR_MESSAGE() ResultMessage              
 END CATCH                
    end   
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateMediaGalleryPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
    
CREATE Procedure [dbo].[InsertUpdateMediaGalleryPublish]      
@MediaId nvarchar(100) ,      
@Status nvarchar(10),      
@CreatedBy nvarchar(100) ,      
@CIPAddress nvarchar(100)       
      
As      
begin      
Begin Tran      
begin try      
if not exists(select * from cmsMediaGalleryPublish where MediaId=@MediaId)    
begin    
Insert into cmsMediaGalleryPublish(
       [MediaId]
       ,[MediaCategory]
      ,[MediaType]
      ,[MediaTitle]
      ,[MediaContent]
      ,[MediaTitleHindi]
      ,[MediaContentHindi]
      ,[MediaPath]
      ,[Version]
      ,[FileSize],Status,CreatedBy,CIPAddress,CreatedOn) 
      (Select 
	  MediaId,
	  [MediaCategory]
      ,[MediaType]
      ,[MediaTitle]
      ,[MediaContent]
      ,[MediaTitleHindi]
      ,[MediaContentHindi]
      ,[MediaPath]
      ,[Version]
      ,[FileSize],@Status,@CreatedBy,@CIPAddress,GETDATE() from cmsMediaGalleryPublish where MediaId=@MediaId)      
    
Update cmsMediaGallery set     
UpdatedBy=@CreatedBy,    
UpdatedOn=GETDATE(),    
Status=@Status    
where MediaId=@MediaId    
    
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage      
end    
else    
begin    
if exists(select * from cmsMediaGalleryPublish where MediaId=@MediaId)    
begin    
    
Update cmsMediaGalleryPublish set     
       MediaId=publish.MediaId
      , MediaCategory=publish.MediaCategory
      ,MediaType=publish.MediaType
      ,MediaTitle=publish.MediaTitle
      ,MediaContent=publish.MediaContent
      ,MediaTitleHindi=publish.MediaTitleHindi
      ,MediaContentHindi=publish.MediaContentHindi
      ,MediaPath=publish.MediaPath
      ,Version=publish.Version
      ,FileSize=publish.FileSize,
UpdatedBy=@CreatedBy,    
UpdatedOn=GETDATE(),    
Status=@Status   
from cmsMediaGallery p inner join cmsMediaGalleryPublish publish on p.MediaId=publish.MediaId
where p.MediaId=@MediaId;    
    
    
Update cmsMediaGallery set     
UpdatedBy=@CreatedBy,    
UpdatedOn=GETDATE(),    
Status=@Status    
    
where MediaId=@MediaId    
    
    
    
if(@Status ='P')    
begin    
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage     
end    
else    
begin    
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage     
end    
end    
else    
begin    
Select 'f' ResultStatus, 'Updated failed' ResultMessage      
end     
end    
commit      
end try      
begin catch      
Select 'f' ResultStatus, 'Exception Error' ResultMessage      
end catch      
      
end      
      
      
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateMenu]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                      
CREATE Procedure [dbo].[InsertUpdateMenu]                        
@MenuId nvarchar(100) ,                        
@ParentId nvarchar(100) ,                  
@PageId nvarchar(100) ,                  
@Path nvarchar(100) ,                  
@Target nvarchar(100) ,                  
@LinkType nvarchar(100) ,                  
@Priority nvarchar(100),               
@MenuName nvarchar(100)       ,               
@CreatedBy nvarchar(100)       ,               
@CIPAddress nvarchar(100)       ,               
@MenuNameHindi nvarchar(100)                      
                        
As                        
begin                        
Begin Tran                        
begin try                        
if(@MenuId is null)                      
begin                      
if not exists(select * from cmsPublicMenu where MenuName=@MenuName)                      
begin                
Insert into cmsPublicMenu(MenuName,MenuNameHindi,Path,LinkType,Target, Status,ParentId,Priority,PageId,CIPAddress,CreatedBy,CreatedOn)         
values(@MenuName,@MenuNameHindi,@Path,@LinkType,@Target,'D',@ParentId,@Priority,@PageId,@CIPAddress,@CreatedBy,GETDATE())                       

Insert into cmsPublicMenu_History(MenuId, MenuName,MenuNameHindi,Path,LinkType,Target, Status,ParentId,Priority,PageId,CIPAddress,CreatedBy,CreatedOn,ActionBy,ActionName,ActionOn)         
values(@@IDENTITY, @MenuName,@MenuNameHindi,@Path,@LinkType,@Target,'D',@ParentId,@Priority,@PageId,@CIPAddress,@CreatedBy,GETDATE(),@CreatedBy,'Inserted',GETDATE())                       


Select 't' ResultStatus, 'Data Added Successfully.' ResultMessage                        
end                
else                
begin        
Select 'f' ResultStatus, 'Menu Name Already exists' ResultMessage       
end                
end                      
else                      
begin                      
if exists(select * from cmsPublicMenu where MenuId=@MenuId)                      
begin                      
Update cmsPublicMenu set MenuName=@MenuName,MenuNameHindi=@MenuNameHindi,ParentId=@ParentId,Status='D',        
Priority=@Priority,PageId=@PageId ,Path=@Path,Target=@Target,  LinkType=@LinkType,  
UpdatedBy=@CreatedBy,UpdatedOn=GETDATE(),UIPAddress=@CIPAddress        
        
where MenuId=@MenuId                      
Select 't' ResultStatus, 'Data Updated Successfully.' ResultMessage                       
end                      
else                      
begin                      
Select 'f' ResultStatus, 'Updated failed' ResultMessage                        
end                       
end                      
commit                        
end try                        
begin catch                        
Select 'f' ResultStatus, 'Exception Error' ResultMessage                        
end catch                        
end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateNotification]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
            
                   
CREATE Procedure [dbo].[InsertUpdateNotification]                          
@NotificationId int =null,              
@DescriptionHindi nvarchar(3000)=null,        
@Description nvarchar(2000)=null,        
@ExpiryDate varchar(20)=null,          
@StartDate varchar(20)=null,          
@Type varchar(50) =null,  
@PageId int =null,  
@Path varchar(500)=null,  
@LinkType varchar(10) =null,  
@Target varchar(10) =null,  
@Priority varchar(10) =null,  
@NewGIF varchar(200) =null,  
@CreatedBy  varchar(50)=null,                      
@CIPAddress  varchar(50)=null                      
                      
 AS                          
 begin                        
 BEGIN TRAN                          
 BEGIN TRY                 
 if exists(select * from cmsNotification where NotificationId=@NotificationId)                        
  begin                        
              
    Update cmsNotification set           
 ExpiryDate=Convert(date,@ExpiryDate,103),            
 StartDate=Convert(date,@StartDate,103),      
  DescriptionHindi=@DescriptionHindi,              
  Description=@Description,       
           
  Type=@Type,     
  PageId=@PageId,     
  Path=@Path,     
  LinkType=@LinkType,     
  Target=@Target,     
  Priority=@Priority,     
  NewGIF=@NewGIF,     
             
  Status='D',      
  UIPAddress=@CIPAddress,              
  UpdatedBy=@CreatedBy,              
  UpdatedOn=GETDATE()              
  Where NotificationId=@NotificationId              
            
  select 't' ResultStatus  , 'Data Updated Successfull.' ResultMessage ,@NotificationId as Id              
              
  end                        
  else                        
   Insert Into cmsNotification(Description,DescriptionHindi,ExpiryDate,StartDate,  
   Type, PageId,Path,LinkType,Target,Priority,  NewGIF,   
   Status,CreatedOn,CreatedBy,CIPAddress)                          
      values(@Description,@DescriptionHindi,Convert(date,@ExpiryDate,103),Convert(date,@StartDate,103),  
   @Type,@PageId,@Path, @LinkType, @Target, @Priority, @NewGIF,    
   'D',GETDATE(),@CreatedBy,@CIPAddress)                  
                         
     select 't' ResultStatus  , 'Notification Created Successfull.' ResultMessage ,@@IDENTITY Id                         
                      
  COMMIT TRAN                          
 END TRY                          
 BEGIN CATCH                          
 select 'f' ResultStatus  ,ERROR_MESSAGE() ResultMessage                        
 END CATCH                          
    end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateNotificationPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
            
              
CREATE Procedure [dbo].[InsertUpdateNotificationPublish]                
@NotificationId nvarchar(100) ,                
@Status nvarchar(10),                
@CreatedBy nvarchar(100) ,                
@CIPAddress nvarchar(100)                 
                
As                
begin                
Begin Tran                
begin try                
if not exists(select * from cmsNotificationPublish where NotificationId=@NotificationId)              
begin              
Insert into cmsNotificationPublish(NotificationId,Description,DescriptionHindi,ExpiryDate,StartDate,Type, PageId,Path,LinkType,Target,Priority,NewGIF,Status,CreatedBy,CIPAddress,CreatedOn)     
(select NotificationId,Description,DescriptionHindi,ExpiryDate,StartDate,Type, PageId,Path,LinkType,Target,Priority,NewGIF,@Status,@CreatedBy,@CIPAddress,GETDATE()     
from cmsNotification where NotificationId=@NotificationId)                
              
Update cmsNotification set               
UpdatedBy=@CreatedBy,              
UpdatedOn=GETDATE(),              
Status=@Status              
where NotificationId=@NotificationId              
              
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage                
end              
else              
begin              
if exists(select * from cmsNotificationPublish where NotificationId=@NotificationId)              
begin              
              
Update publish set      
publish.Description=p.Description,    
publish.DescriptionHindi=p.DescriptionHindi,    
publish.ExpiryDate=p.ExpiryDate,    
publish.StartDate=p.StartDate,        
 publish.Type=p.Type,   
 publish.PageId=p.PageId,   
 publish.Path=p.Path,   
 publish.LinkType=p.LinkType,   
 publish.Target=p.Target,   
 publish.Priority=p.Priority,   
 publish.NewGIF=p.NewGIF,   
publish.UpdatedBy=@CreatedBy,              
publish.UpdatedOn=GETDATE(),              
publish.Status=@Status          
    
from cmsNotification p     
inner Join cmsNotificationPublish publish on  p.NotificationId=publish.NotificationId       
where p.NotificationId=@NotificationId;              
              
              
Update cmsNotification set               
UpdatedBy=@CreatedBy,              
UpdatedOn=GETDATE(),              
Status=@Status              
              
where NotificationId=@NotificationId              
              
              
              
if(@Status ='P')              
begin              
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage               
end              
else              
begin              
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage               
end              
end              
else              
begin              
Select 'f' ResultStatus, 'Updated failed' ResultMessage                
end               
end              
commit                
end try                
begin catch                
Select 'f' ResultStatus, 'Exception Error' ResultMessage                
end catch                
                
end   
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdatePages]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                
                        
CREATE Procedure [dbo].[InsertUpdatePages]                        
@PageId    nvarchar(500)=null,                  
@DepartmentId    nvarchar(500)=null,                  
@MetaContent nvarchar(max)=null,                  
@MetaTitle nvarchar(500)=null,                  
@PageContent nvarchar(max)=null,                  
@PageName   nvarchar(500)=null,                  
@PageTitle  nvarchar(500)=null,              
@PageContentHindi nvarchar(MAX) =null,              
@PageTitleHindi nvarchar(100) =null,                
@UpdatedBy  nvarchar(500)=null,                
@UIPAddress  nvarchar(500)=null                
                        
                        
As                        
begin                        
Begin Tran                        
begin try                        
                 
              
  if(@PageId= '0')                  
   begin                  
    if exists(select * from cmsPages where PageName=@PageName)            
   begin            
    Select 'f' ResultStatus, 'Page name already exists.' ResultMessage                
   end            
   else            
   begin            
    Insert into cmsPages(PageName,DepartmentId,  MetaTitle,MetaContent,PageTitle,PageContent,PageContentHindi,PageTitleHindi,ContentModifyStatus,CreatedOn,CreatedBy,CIPAddress,Status)                         
              values(@PageName,@DepartmentId,@MetaTitle,@MetaContent,@PageTitle,@PageContent,@PageContentHindi,@PageTitleHindi,'D',GETDATE(),@UpdatedBy,@UIPAddress,'D')                        
 Insert into cmsPagesHistory(PageId, PageName,DepartmentId,  MetaTitle,MetaContent,PageTitle,PageContent,PageContentHindi,PageTitleHindi,ContentModifyStatus,CreatedOn,CreatedBy,CIPAddress,Status,ActionBy,ActionName,ActionOn)                         
              values(@@IDENTITY,@PageName,@DepartmentId,@MetaTitle,@MetaContent,@PageTitle,@PageContent,@PageContentHindi,@PageTitleHindi,'D',GETDATE(),@UpdatedBy,@UIPAddress,'D',@UpdatedBy,'Inserted',GETDATE())                        
   
  Select 't' ResultStatus, 'Data Added Successfully.' ResultMessage, @@IDENTITY Id                    
  end            
end                  
else                  
begin                  
if exists(Select * from cmsPages where PageId=@PageId)                    
begin                    
Update cmsPages Set              
DepartmentId=@DepartmentId,             
PageContent=@PageContent,             
  MetaTitle=@MetaTitle,    
  MetaContent=@MetaContent,           
PageName=@PageName,                    
PageContentHindi=@PageContentHindi,          
PageTitleHindi=@PageTitleHindi,          
ContentModifyStatus='D',          
PageTitle=@PageTitle,                      
UpdatedBy=@UpdatedBy,                
UpdatedOn=GETDATE(),UIPAddress=@UIPAddress where PageId=@PageId                   
                
Select 't' ResultStatus, 'Data Updated Successfully.' ResultMessage                    
end                    
else                    
begin                    
Select 'f' ResultStatus, 'Data update failed because data not found.' ResultMessage                    
end                    
end                  
                      
commit                        
end try                        
begin catch                        
   declare @error int, @message varchar(4000), @xstate int;                
  select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();                
--Select 'f' ResultStatus, 'Exception Error' ResultMessage                        
end catch                        
                        
end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdatePagesPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
            
            
CREATE Procedure [dbo].[InsertUpdatePagesPublish]              
@PageId nvarchar(100) ,              
@Status nvarchar(10),              
@CreatedBy nvarchar(100) ,              
@CIPAddress nvarchar(100)               
              
As              
begin              
Begin Tran              
begin try              
if not exists(select * from cmsPagesPublish where PageId=@PageId)            
begin            
Insert into cmsPagesPublish        
(PageId,DepartmentId,  MetaTitle,MetaContent,PageName,PageTitle,PageContent,PageContentHindi,PageTitleHindi,ContentModifyStatus,Status,CreatedBy,CIPAddress,CreatedOn)         
(Select PageId,DepartmentId, MetaTitle,MetaContent,PageName,PageTitle,PageContent,PageContentHindi,PageTitleHindi,'P',@Status,@CreatedBy,@CIPAddress,GETDATE() from cmsPages where PageId=@PageId)              
            
                
Update cmsPages set             
UpdatedBy=@CreatedBy,            
UpdatedOn=GETDATE(),           
ContentModifyStatus=@Status ,         
Status=@Status         
 Where  PageId=@PageId

Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage              
end            
else            
begin            
if exists(select * from cmsPagesPublish where PageId=@PageId)            
begin            
      Update publishPage set             
   publishPage.DepartmentId=p.DepartmentId,    
   publishPage.MetaTitle=p.MetaTitle,    
   publishPage.MetaContent=p.MetaContent,    
publishPage.PageName=p.PageName,        
publishPage.PageTitle=p.PageTitle,        
publishPage.PageContent=p.PageContent,        
publishPage.PageContentHindi=p.PageContentHindi,        
publishPage.PageTitleHindi=p.PageTitleHindi,        
publishPage.ContentModifyStatus=@Status,        
publishPage.UpdatedBy=@CreatedBy,            
publishPage.UpdatedOn=GETDATE(),            
publishPage.Status=@Status            
        
 from cmsPages p inner join cmsPagesPublish publishPage on p.PageId=publishPage.PageId        
where publishPage.PageId=@PageId        
      
         
            
            
Update cmsPages set             
UpdatedBy=@CreatedBy,            
UpdatedOn=GETDATE(),           
ContentModifyStatus=@Status ,         
Status=@Status            
            
where PageId=@PageId            
            
            
            
if(@Status ='P')            
begin            
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage             
end            
else            
begin            
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage             
end            
end            
else            
begin            
Select 'f' ResultStatus, 'Updated failed' ResultMessage              
end             
end            
commit              
end try              
begin catch              
Select 'f' ResultStatus, 'Exception Error' ResultMessage              
end catch              
              
end   
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdatePublicMenuPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
CREATE Procedure [dbo].[InsertUpdatePublicMenuPublish]            
@MenuId nvarchar(100) ,            
@Status nvarchar(10),            
@CreatedBy nvarchar(100) ,            
@CIPAddress nvarchar(100)             
            
As            
begin            
Begin Tran            
begin try            
if not exists(select * from cmsPublicMenuPublish where MenuId=@MenuId)          
begin          
     
Insert into cmsPublicMenuPublish(MenuId,ModuleId,MenuName,MenuNameHindi,ParentId,PageId,Priority ,LinkType,Path,Target,Status, CreatedBy,CIPAddress,CreatedOn)      
(select MenuId,ModuleId,MenuName,MenuNameHindi,ParentId,PageId,Priority ,LinkType,Path,Target,@Status,@CreatedBy,@CIPAddress,GETDATE() from cmsPublicMenu where MenuId=@MenuId )      
      
Update cmsPublicMenu set          
Status=@Status  ,      
UpdatedBy=@CreatedBy,          
UpdatedOn=GETDATE(),          
UIPAddress=@CIPAddress      
      
where MenuId=@MenuId          
      
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage            
end          
else          
begin          
if exists(select * from cmsPublicMenuPublish where MenuId=@MenuId)          
begin          
          
Update pubMenuupdate set           
pubMenuupdate.MenuName=s.MenuName,    
pubMenuupdate.MenuNameHindi=s.MenuNameHindi,    
pubMenuupdate.ParentId=s.ParentId,    
pubMenuupdate.PageId=s.PageId,    
pubMenuupdate.ModuleId=s.ModuleId,    
pubMenuupdate.Priority=s.Priority,    
pubMenuupdate.LinkType=s.LinkType,    
pubMenuupdate.Path=s.Path,    
pubMenuupdate.Target=s.Target,    
UpdatedBy=@CreatedBy,          
UpdatedOn=GETDATE(),          
Status=@Status    ,      
UIPAddress=@CIPAddress      
    
from cmsPublicMenu s inner join cmsPublicMenuPublish pubMenuupdate on s.MenuId=pubMenuupdate.MenuId    
    
where pubMenuupdate.MenuId=@MenuId;          
          
          
Update cmsPublicMenu set           
Status=@Status    ,      
UpdatedBy=@CreatedBy,          
UpdatedOn=GETDATE(),          
UIPAddress=@CIPAddress      
          
where MenuId=@MenuId          
          
          
          
if(@Status ='P')          
begin          
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage           
end          
else          
begin          
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage           
end          
end          
else          
begin          
Select 'f' ResultStatus, 'Updated failed' ResultMessage            
end           
end          
commit            
end try            
begin catch            
Select 'f' ResultStatus, 'Exception Error' ResultMessage            
end catch            
            
end   
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateSection]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

          
CREATE Procedure [dbo].[InsertUpdateSection]          
       
  
@SectionId    nvarchar(500)=null,    
@PageId    nvarchar(500)=null,    
@SectionContent nvarchar(max)=null,    
@SectionName   nvarchar(500)=null,    
@SectionTitle  nvarchar(500)=null,  
@UpdatedBy  nvarchar(500)=null,  
@UIPAddress  nvarchar(500)=null  
          
          
As          
begin          
Begin Tran          
begin try          
    
  if(@SectionId= '0')    
   begin    
    Insert into cmsSection(PageId,SectionName,SectionTitle,SectionContent,CreatedOn,UpdatedBy,UIPAddress,Status)           
              values(@PageId,@SectionName,@SectionTitle,@SectionContent,GETDATE(),@UpdatedBy,@UIPAddress,'D')          
  Select 't' ResultStatus, 'Data Added Successfully.' ResultMessage, @@IDENTITY Id      
end    
else    
begin    
if exists(Select * from cmsSection where SectionId=@SectionId)      
begin      
Update cmsSection Set    
PageId=@PageId,   
SectionContent=@SectionContent,      
SectionName=@SectionName,      
SectionTitle=@SectionTitle,        
UpdatedBy=@UpdatedBy,  
UpdatedOn=GETDATE(),UIPAddress=@UIPAddress where SectionId=@SectionId     
  
Select 't' ResultStatus, 'Data Updated Successfully.' ResultMessage      
end      
else      
begin      
Select 'f' ResultStatus, 'Data update failed because data not found.' ResultMessage      
end      
end    
        
commit          
end try          
begin catch          
   declare @error int, @message varchar(4000), @xstate int;  
  select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();  
--Select 'f' ResultStatus, 'Exception Error' ResultMessage          
end catch          
          
end          
          
          
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateSectionPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
Create Procedure [dbo].[InsertUpdateSectionPublish]      
@SectionId nvarchar(100) ,      
@Status nvarchar(10),      
@CreatedBy nvarchar(100) ,      
@CIPAddress nvarchar(100)       
      
As      
begin      
Begin Tran      
begin try      
if not exists(select * from cmsSectionPublish where SectionId=@SectionId)    
begin    
Insert into cmsSectionPublish(SectionId,Status,CreatedBy,CIPAddress,CreatedOn) values(@SectionId,@Status,@CreatedBy,@CIPAddress,GETDATE())      
    
Update cmsSection set     
UpdatedBy=@CreatedBy,    
UpdatedOn=GETDATE(),    
Status=@Status    
where SectionId=@SectionId    
    
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage      
end    
else    
begin    
if exists(select * from cmsSectionPublish where SectionId=@SectionId)    
begin    
    
Update cmsSectionPublish set     
UpdatedBy=@CreatedBy,    
UpdatedOn=GETDATE(),    
Status=@Status    
where SectionId=@SectionId;    
    
    
Update cmsSection set     
UpdatedBy=@CreatedBy,    
UpdatedOn=GETDATE(),    
Status=@Status    
    
where SectionId=@SectionId    
    
    
    
if(@Status ='P')    
begin    
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage     
end    
else    
begin    
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage     
end    
end    
else    
begin    
Select 'f' ResultStatus, 'Updated failed' ResultMessage      
end     
end    
commit      
end try      
begin catch      
Select 'f' ResultStatus, 'Exception Error' ResultMessage      
end catch      
      
end      
      
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateTender]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                        
CREATE Procedure [dbo].[InsertUpdateTender]                        
@tenderId bigint=null  ,      
@tenderTitle varchar(200)=null ,       
@tenderRefNo varchar(200)=null ,       
@productCategory varchar(200)=null ,       
@subCategory varchar(200)=null ,       
@tenderValueType varchar(100)=null ,       
@tenderValue varchar(100)=null ,       
@emd varchar(100)=null ,       
@documentCost varchar(100)=null ,       
@tenderType varchar(100)=null ,       
@biddingType varchar(100)=null ,       
@limited varchar(100) =null ,       
@location varchar(100)=null ,       
@firstAnnouncementDate varchar(100)=null ,       
@lastDateOfCollection varchar(100)=null ,       
@lastDateForSubmission varchar(100)=null ,       
@openingDate varchar(100)=null ,       
@workDescription nvarchar(MAX)=null ,       
@preQualification nvarchar(MAX)=null ,       
@preBidMeet varchar(100)=null ,       
@format1 varchar(100)=null ,       
@format2 varchar(100)=null ,       
@format3 varchar(100)=null ,       
@format4 varchar(100)=null ,       
@format5 varchar(100)=null ,       
@depName varchar(200)=null ,       
@recievingDate varchar(100)=null ,      
@PublishedDate varchar(100)=null ,      
@UnderEvaluation varchar(100)=null ,      
@LastDateOfEvaluation varchar(100)=null ,      
@ExpiryDate varchar(100)=null ,      
@CreatedBy nvarchar(100)=null ,                        
@CreatedOn nvarchar(20)=null ,                        
@CIPAddress nvarchar(100) =null                        
                        
                        
As                        
begin                        
Begin Tran                        
begin try                        
                  
  if(@tenderId= '0')                  
   begin                  
    Insert into cmsTenders(tenderTitle,tenderRefNo,productCategory,subCategory,tenderValueType,status,ExpiryDate,PublishedDate      
      ,tenderValue,emd,documentCost,tenderType,biddingType,limited,location,firstAnnouncementDate,  
	  UnderEvaluation,LastDateOfEvaluation  
      ,lastDateOfCollection,lastDateForSubmission,openingDate,workDescription,preQualification,preBidMeet      
      ,format1,format2,format3,format4,format5,createDate,depName,recievingDate,CreatedBy,CIPAddress)          
                        
              values(@tenderTitle,@tenderRefNo,@productCategory,@subCategory,@tenderValueType,'D',@ExpiryDate,@PublishedDate        
      ,@tenderValue,@emd,@documentCost,@tenderType,@biddingType,@limited,@location,@firstAnnouncementDate,  
	   @UnderEvaluation,@LastDateOfEvaluation    
      ,@lastDateOfCollection,@lastDateForSubmission,@openingDate,@workDescription,@preQualification,@preBidMeet      
      ,@format1,@format2,@format3,@format4,@format5,GetDate(),@depName,@recievingDate,@CreatedBy,@CIPAddress)        
                         
  Select 't' ResultStatus, 'Data Added Successfully.' ResultMessage, @@IDENTITY Id                    
end                  
else                  
begin                  
if exists(Select * from cmsTenders where tenderId=@tenderId)                    
begin                    
Update cmsTenders Set                    
      
tenderTitle= @tenderTitle,      
tenderRefNo=@tenderRefNo,      
productCategory=@productCategory,      
subCategory=@subCategory,      
tenderValueType=@tenderValueType,      
tenderValue=@tenderValue,      
emd=@emd,      
documentCost=@documentCost,      
tenderType=@tenderType,      
biddingType=@biddingType,      
limited=@limited,      
location=@location,      
firstAnnouncementDate=@firstAnnouncementDate,      
lastDateOfCollection=@lastDateOfCollection,      
lastDateForSubmission=@lastDateForSubmission,      
openingDate=@openingDate,      
workDescription=@workDescription,      
preQualification=@preQualification,      
preBidMeet=@preBidMeet,      
format1=@format1,      
format2=@format2,      
format3=@format3,      
format4=@format4,      
format5=@format5,      
depName=@depName,      
recievingDate=@recievingDate,              
ExpiryDate=@ExpiryDate,              
PublishedDate=@PublishedDate,              
UnderEvaluation=@UnderEvaluation,              
LastDateOfEvaluation=@LastDateOfEvaluation,              
Status='D',             
UpdatedBy=@CreatedBy,modifyDate=GETDATE(),UIPAddress=@CIPAddress where tenderId=@tenderId                   
                
Select 't' ResultStatus, 'Data Updated Successfully.' ResultMessage,    @tenderId  Id                
end                    
else                    
begin                    
Select 'f' ResultStatus, 'Data update failed because data not found.' ResultMessage                    
end                    
end                  
                      
commit                        
end try                        
begin catch                        
   declare @error int, @message varchar(4000), @xstate int;                
  select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();                
--Select 'f' ResultStatus, 'Exception Error' ResultMessage                        
end catch                        
                        
end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateTenderCategory]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[InsertUpdateTenderCategory]  
@CategoryId nvarchar(100) ,  
@CategoryName nvarchar(100) ,  
@CreatedBy nvarchar(100) ,  
@CIPAddress nvarchar(100)   
  
As  
begin  
Begin Tran  
begin try  
if(@CategoryId is null)
begin
Insert into cmsTenderCategory(CategoryName,Status,CreatedBy,CIPAddress,CreatedOn) values(@CategoryName,'D',@CreatedBy,@CIPAddress,GETDATE())  
Select 't' ResultStatus, 'Data Added Successfully.' ResultMessage  
end
else
begin
if exists(select * from cmsTenderCategory where CategoryId=@CategoryId)
begin
Update cmsTenderCategory set CategoryName=@CategoryName,UpdatedBy=@CreatedBy,
UpdatedOn=GETDATE() where CategoryId=@CategoryId
Select 't' ResultStatus, 'Data Updated Successfully.' ResultMessage 
end
else
begin
Select 'f' ResultStatus, 'Updated failed' ResultMessage  
end 
end
commit  
end try  
begin catch  
Select 'f' ResultStatus, 'Exception Error' ResultMessage  
end catch  
end  
  
  
  
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateTenderCategoryPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[InsertUpdateTenderCategoryPublish]  
@CategoryId nvarchar(100) ,  
@Status nvarchar(10),  
@CreatedBy nvarchar(100) ,  
@CIPAddress nvarchar(100)   
  
As  
begin  
Begin Tran  
begin try  
if not exists(select * from cmsTenderCategoryPublish where CategoryId=@CategoryId)
begin
Insert into cmsTenderCategoryPublish(CategoryId,Status,CreatedBy,CIPAddress,CreatedOn) values(@CategoryId,@Status,@CreatedBy,@CIPAddress,GETDATE())  

Update cmsTenderCategory set 
UpdatedBy=@CreatedBy,
UpdatedOn=GETDATE(),
Status=@Status
where CategoryId=@CategoryId

Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage  
end
else
begin
if exists(select * from cmsTenderCategoryPublish where CategoryId=@CategoryId)
begin

Update cmsTenderCategoryPublish set 
UpdatedBy=@CreatedBy,
UpdatedOn=GETDATE(),
Status=@Status
where CategoryId=@CategoryId;


Update cmsTenderCategory set 
UpdatedBy=@CreatedBy,
UpdatedOn=GETDATE(),
Status=@Status

where CategoryId=@CategoryId



if(@Status ='P')
begin
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage 
end
else
begin
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage 
end
end
else
begin
Select 'f' ResultStatus, 'Updated failed' ResultMessage  
end 
end
commit  
end try  
begin catch  
Select 'f' ResultStatus, 'Exception Error' ResultMessage  
end catch  
  
end  
  
  
  
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateTenderDocs]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                    
CREATE Procedure [dbo].[InsertUpdateTenderDocs]                    
@tenderDocsId	int	=null ,    
@tenderId	int	=null ,    
@corrigendumTitle	varchar(200)	=null ,    
@tenderDocument	varchar(100)	=null ,    
@CreatedBy nvarchar(100)=null ,                    
@CIPAddress nvarchar(100) =null                    
                    
                    
As                    
begin                    
Begin Tran                    
begin try                    
              
  if(@tenderDocsId= '0')              
   begin              
    Insert into cmsTenderDocs(tenderId,corrigendumTitle,tenderDocument,createDate,status,CreatedBy,CIPAddress)      
                       values(@tenderId,@corrigendumTitle,@tenderDocument,GETDATE(),'D',@CreatedBy,@CIPAddress)    
                     
  Select 't' ResultStatus, 'Document Added Successfully.' ResultMessage, @@IDENTITY Id                
end              
else              
begin              
if exists(Select * from cmsTenderDocs where tenderDocsId=@tenderDocsId)                
begin                
Update cmsTenderDocs Set                
  corrigendumTitle=@corrigendumTitle,
  tenderDocument=@tenderDocument,
Status='D',         
UpdatedBy=@CreatedBy,modifyDate=GETDATE(),UIPAddress=@CIPAddress where tenderDocsId=@tenderDocsId               
            
Select 't' ResultStatus, 'Data Updated Successfully.' ResultMessage,    @tenderDocsId  Id            
end                
else                
begin                
Select 'f' ResultStatus, 'Data update failed because data not found.' ResultMessage                
end                
end              
                  
commit                    
end try                    
begin catch                    
   declare @error int, @message varchar(4000), @xstate int;            
  select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();            
--Select 'f' ResultStatus, 'Exception Error' ResultMessage                    
end catch                    
                    
end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateTenderPublish]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
      
CREATE Procedure [dbo].[InsertUpdateTenderPublish]        
@TenderId nvarchar(100) ,        
@Status nvarchar(10),        
@CreatedBy nvarchar(100) ,        
@CIPAddress nvarchar(100)         
        
As        
begin        
Begin Tran        
begin try        
if not exists(select * from cmsTenderPublish where TenderId=@TenderId)      
begin      
Insert into cmsTenderPublish(  
      tenderId  
      ,nameOfOrganization  
      ,typeOfOrganization  
      ,tenderTitle  
      ,tenderRefNo  
      ,productCategory  
      ,subCategory  
      ,tenderValueType  
      ,tenderValue  
      ,emd  
      ,documentCost  
      ,tenderType  
      ,biddingType  
      ,limited  
      ,location  
      ,firstAnnouncementDate  
      ,lastDateOfCollection  
      ,lastDateForSubmission  
      ,openingDate  
      ,workDescription  
      ,preQualification  
      ,preBidMeet  
      ,tenderDocument  
      ,tenderDocument1  
      ,tenderDocument2  
      ,tenderDocument3  
      ,tenderDocument4  
      ,tenderDocument5  
      ,tenderDocument6  
      ,tenderDocument7  
      ,extradoc  
      ,extradoc1  
      ,extradoc2  
      ,tenderDocumentExtra  
      ,hindiDocs  
      ,linkName  
      ,linkName1  
      ,linkName2  
      ,linkName3  
      ,linkName4  
      ,format1  
      ,format2  
      ,format3  
      ,format4  
      ,format5  
      ,ExpiryDate  
      ,PublishedDate  

      ,UnderEvaluation,LastDateOfEvaluation  ,depName  
      ,recievingDate  
      ,assignTo  
      ,descriptionOfAssign  
    ,status  
      ,CreatedBy  
      ,CIPAddress  
     ,createDate  
      )     
(Select tenderId  
      ,nameOfOrganization  
      ,typeOfOrganization  
      ,tenderTitle  
      ,tenderRefNo  
      ,productCategory  
      ,subCategory  
      ,tenderValueType  
      ,tenderValue  
      ,emd  
      ,documentCost  
      ,tenderType  
      ,biddingType  
      ,limited  
      ,location  
      ,firstAnnouncementDate  
      ,lastDateOfCollection  
      ,lastDateForSubmission  
      ,openingDate  
      ,workDescription  
      ,preQualification  
      ,preBidMeet  
      ,tenderDocument  
      ,tenderDocument1  
      ,tenderDocument2  
      ,tenderDocument3  
      ,tenderDocument4  
      ,tenderDocument5  
      ,tenderDocument6  
      ,tenderDocument7  
      ,extradoc  
      ,extradoc1  
      ,extradoc2  
      ,tenderDocumentExtra  
      ,hindiDocs  
      ,linkName  
      ,linkName1  
      ,linkName2  
      ,linkName3  
      ,linkName4  
      ,format1  
      ,format2  
      ,format3  
      ,format4  
      ,format5  
      ,ExpiryDate  
      ,PublishedDate  
      ,UnderEvaluation,LastDateOfEvaluation  ,depName  
      ,recievingDate  
      ,assignTo  
      ,descriptionOfAssign, @Status,@CreatedBy,@CIPAddress,GETDATE() from cmsTenders where TenderId=@TenderId)        
      
Update cmsTenders set       
UpdatedBy=@CreatedBy,      
modifyDate=GETDATE(),      
Status=@Status      
where TenderId=@TenderId      
      
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage        
end      
else      
begin      
if exists(select * from cmsTenderPublish where TenderId=@TenderId)      
begin      
      
Update TenderPublish set      
       
      nameOfOrganization=t.nameOfOrganization  
      ,typeOfOrganization=t.typeOfOrganization  
      ,tenderTitle=t.tenderTitle  
      ,tenderRefNo=t.tenderRefNo  
      ,productCategory=t.productCategory  
      ,subCategory=t.subCategory  
      ,tenderValueType=t.tenderValueType  
      ,tenderValue=t.tenderValue  
      ,emd=t.emd  
      ,documentCost=t.documentCost  
      ,tenderType=t.tenderType  
      ,biddingType=t.biddingType  
      ,limited=t.limited  
      ,location=t.location  
      ,firstAnnouncementDate=t.firstAnnouncementDate  
      ,lastDateOfCollection=t.lastDateOfCollection  
      ,lastDateForSubmission=t.lastDateForSubmission  
      ,openingDate=t.openingDate  
      ,workDescription=t.workDescription  
      ,preQualification=t.preQualification  
      ,preBidMeet=t.preBidMeet  
      ,tenderDocument=t.tenderDocument  
      ,tenderDocument1=t.tenderDocument1  
      ,tenderDocument2=t.tenderDocument2  
      ,tenderDocument3=t.tenderDocument3  
      ,tenderDocument4=t.tenderDocument4  
      ,tenderDocument5=t.tenderDocument5  
      ,tenderDocument6=t.tenderDocument6  
      ,tenderDocument7=t.tenderDocument7  
      ,extradoc=t.extradoc  
      ,extradoc1=t.extradoc1  
      ,extradoc2=t.extradoc2  
      ,tenderDocumentExtra=t.tenderDocumentExtra  
      ,hindiDocs=t.hindiDocs  
      ,linkName=t.linkName  
      ,linkName1=t.linkName1  
      ,linkName2=t.linkName2  
      ,linkName3=t.linkName3  
      ,linkName4=t.linkName4  
      ,format1=t.format1  
      ,format2=t.format2  
      ,format3=t.format3  
      ,format4=t.format4  
      ,format5=t.format5  
      ,ExpiryDate=t.ExpiryDate  
      ,PublishedDate=t.PublishedDate  
	  ,UnderEvaluation=t.UnderEvaluation
	  ,LastDateOfEvaluation=t.LastDateOfEvaluation  
      ,depName=t.depName  
      ,recievingDate=t.recievingDate  
      ,assignTo=t.assignTo  
      ,descriptionOfAssign=t.descriptionOfAssign,  
UpdatedBy=@CreatedBy,      
modifyDate=GETDATE(),      
Status=@Status      
    
from cmsTenders t inner join cmstenderPublish TenderPublish on t.TenderId=TenderPublish.TenderId    
where TenderPublish.TenderId=@TenderId;      
      
      
Update cmsTenders set       
UpdatedBy=@CreatedBy,      
modifyDate=GETDATE(),      
Status=@Status      
      
where TenderId=@TenderId      
      
      
      
if(@Status ='P')      
begin      
Select 't' ResultStatus, 'Data Published Successfully.' ResultMessage       
end      
else      
begin      
Select 't' ResultStatus, 'Data UnPublish Successfully.' ResultMessage       
end      
end      
else      
begin      
Select 'f' ResultStatus, 'Updated failed' ResultMessage        
end       
end      
commit        
end try        
begin catch        
Select 'f' ResultStatus, 'Exception Error' ResultMessage        
end catch        
        
end        
        
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdateUserRights]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
Create Procedure [dbo].[InsertUpdateUserRights]          
@ReferenceApplicationRights ReferenceApplicationRights readonly ,              
@CreatedBy nvarchar(100) =null,          
@IPAddress nvarchar(100) =null          
as          
begin                                                             
         begin try                               
          Merge  cmsApplicationRights WITH (HOLDLOCK) T                                                                                                     
          Using @ReferenceApplicationRights R                                                                                                
          ON (T.MenuId=R.MenuId and T.Role=R.Role)                                                                  
          WHEN MATCHED                                                                                                 
          then   
     
      
    update set T.Role=R.Role ,      
     T.Status=R.Status,      
     T.AllowInsert=R.AllowInsert,      
     T.AllowDelete=R.AllowDelete,      
     T.AllowUpdate=R.AllowUpdate,      
     T.AllowPublish=R.AllowPublish,      
          
          
    T.UpdatedBy=@CreatedBy, T.UpdatedOn=GetDate(),T.IPAddress=@IpAddress                                                                           
          When Not Matched   BY TARGET                                                                                        
          then                                  
          insert(Role,MenuId,AllowInsert,AllowDelete,AllowUpdate,AllowPublish, Status,CreatedBy,CreatedOn,IPAddress)      
    values(R.Role,R.MenuId,R.AllowInsert,R.AllowDelete,R.AllowUpdate,R.AllowPublish,  R.Status,@CreatedBy,GetDate(),@IpAddress) ;                                     
          Select  't' ResultStatus,'Data Summited Successfull' ResultMessage;                                                                
        end try                                        
         begin catch                              
        Select  'f' ResultStatus,'Failed'ResultMessage;                                                    
        end catch                                        
end 
GO
/****** Object:  StoredProcedure [dbo].[InsertUser]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
CREATE Procedure [dbo].[InsertUser]              
 @Id  varchar(10)=null,          
 @Password varchar(500)=null,          
 @DepartmentId varchar(500)=null,          
 @UserName nvarchar (500) NULL,              
 @Email varchar(50)=null,          
 @MobileNo varchar(11)=null,          
 @Role  varchar(50)=null,          
 @CreatedBy  varchar(50)=null,          
 @CIPAddress  varchar(50)=null          
          
 AS              
 if exists(select * from ApplicationUser where Email=@Email)            
  begin            
    select 'f' ResultStatus  , 'Mobile or Email Already Exists.' ResultMessage            
  end            
  else            
  begin            
             
 BEGIN TRAN              
 BEGIN TRY              
 declare @roles varchar(50)=null  
 Set @roles=(Select Role from cmsRole where RoleId=@Role)  
  
   Insert Into ApplicationUser(UserId,DepartmentId, Password,RoleId,Role, MobileNo,UserName,Email,CreatedOn,CreatedBy,CurrentIPAddress)              
      values(@Email,@DepartmentId,@Password,@Role,@roles,@MobileNo,@UserName,@Email,GETDATE(),@CreatedBy,@CIPAddress)              
     select 't' ResultStatus  , 'User Created successfull.' ResultMessage            
          
  COMMIT TRAN              
 END TRY              
 BEGIN CATCH              
 select 'f' ResultStatus  ,ERROR_MESSAGE() ResultMessage            
 END CATCH              
    end 
GO
/****** Object:  StoredProcedure [dbo].[SearchForHomePage]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SearchForHomePage] -- SearchForHomePage 'Recruitment of Experienced Engineers for Metro Railway Projects'
@SearchContent nvarchar(1000)
as

select 
PageTitle as Title, 
PageName as url,
PageTitle as Description
from cmsPagesPublish
where PageContent like '%'+@SearchContent+'%'
union all
Select 
tenderTitle as Title,
'Tenders' as url,
tenderTitle as Description
from cmsTenders where tenderTitle like '%'+@SearchContent+'%' or tenderRefNo like '%'+@SearchContent+'%'
union all
Select 
vacancyTitle as Title,
'Career' as url,
vacancyTitle as Description
from cmsCareer where vacancyTitle like '%'+@SearchContent+'%'
union all
Select 
Question as Title,
'Faq' as url,
Question as Description
from cmsFaqPublish where Question like '%'+@SearchContent+'%' or Answer like '%'+@SearchContent+'%'
GO
/****** Object:  StoredProcedure [dbo].[UpdateApplicationUserBlock]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[UpdateApplicationUserBlock]    
@Id nvarchar(100) ,    
@Status nvarchar(10),    
@CreatedBy nvarchar(100) ,    
@CIPAddress nvarchar(100)     
    
As    
begin    
Begin Tran    
begin try    
if exists(select * from ApplicationUser where Id=@Id)  
begin  
--Insert ApplicationUser_History(Select * from ApplicationUser)

Update ApplicationUser set   
LastUpdatedBy=@CreatedBy,  
isBlock=@Status,
CurrentIPAddress=@CIPAddress,
LastUpdatedOn=GETDATE() 
where Id=@Id  
if(@Status is null)
begin
Select 't' ResultStatus, 'User Unblock Successfully.' ResultMessage    
end
else
begin
Select 't' ResultStatus, 'User Block Successfully.' ResultMessage    
end
end  
else  
begin  
Select 'f' ResultStatus, 'User does not exists' ResultMessage    
end  
commit    
end try    
begin catch    
Select 'f' ResultStatus, 'Exception Error' ResultMessage    
end catch    
    
end    
    
    
GO
/****** Object:  StoredProcedure [dbo].[UpdateDepartmentBlock]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[UpdateDepartmentBlock]    
@DepartmentId bigint =null,    
@Status varchar(10) =null,    
@CreatedBy nvarchar(100)=null,    
@CIPAddress nvarchar(100) =null    
  as    
  begin    
  begin tran    
  begin try    
  begin    
  if exists(select * from cmsDepartment where DepartmentId=@DepartmentId)
  begin
  Update cmsDepartment set     
    Status=@Status,  
  UpdatedBy=@CreatedBy,UpdatedOn=getdate(),UIPAddress=@CIPAddress    
  where DepartmentId=@DepartmentId    
  if(@Status='B')
  begin
  Select 't' ResultStatus, 'Department Blocked Successfull' ResultMessage    
  end
  else
  begin
   Select 't' ResultStatus, 'Department Unblocked Successfull' ResultMessage    
  end
  end
  else
  begin
  Select 'f' ResultStatus, 'Department Not Found' ResultMessage    
  end
  end    
  commit    
  end try    
  begin catch    
  Select 'f' ResultStatus, 'Server Error' ResultMessage    
  end catch    
  end 
GO
/****** Object:  StoredProcedure [dbo].[UpdateMainSite]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
              
CREATE Procedure [dbo].[UpdateMainSite]   -- InsertUpdateMainSitePublish 1,'A' ,'Admin','::1'              
@MainSiteId nvarchar(100) ,                  
@BeforeManuHeader nvarchar(max)=null,                  
@AfterManuHeader nvarchar(max)=null,                  
@Header nvarchar(max)=null,                  
@HeaderHindi nvarchar(max)=null,                  
@Footer nvarchar(max)=null,                  
@FooterHindi nvarchar(max)=null,                  
@CreatedBy nvarchar(100) ,                  
@CIPAddress nvarchar(100)                   
                  
As                  
begin                  
Begin Tran                  
begin try                  
if exists(select * from cmsMainSite where MainSiteId=@MainSiteId)                
begin                       
Update cmsMainSite set                     
Header=@Header,          
Footer=@Footer,          
StatusPublish='D',    
HeaderHindi=@HeaderHindi,          
FooterHindi=@FooterHindi,          
UpdatedBy=@CreatedBy,                
UpdatedOn=GETDATE()            
where MainSiteId=@MainSiteId         
  
Insert into cmsMainSite_History   
Select *,@CreatedBy,'Update',Getdate() from cmsMainSite where MainSiteId=@MainSiteId   
         
                
Select 't' ResultStatus, 'Content Updated Successfully.' ResultMessage                  
end                
else                
begin             
Select 'f' ResultStatus, 'Content Update failed' ResultMessage                     
end                
commit                  
end try                  
begin catch                  
Select 'f' ResultStatus, 'Exception Error' ResultMessage                  
end catch                  
                  
end       
GO
/****** Object:  StoredProcedure [dbo].[UpdateMainSiteInstall]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
      
CREATE Procedure [dbo].[UpdateMainSiteInstall]        
@MainSiteId nvarchar(100) ,        
@Status nvarchar(10),               
@CreatedBy nvarchar(100) ,        
@CIPAddress nvarchar(100)         
        
As        
begin        
--Begin Tran        
--begin try        
if exists(select * from cmsMainSitePublish where MainSiteId=@MainSiteId and StatusPublish='P')          
begin      
if(@Status='I')    
begin
Update cmsMainSite Set Status='A'
Update cmsMainSitePublish Set Status='A'

Update cmsMainSite set           
UpdatedBy=@CreatedBy,          
UpdatedOn=GETDATE(),          
Status='I'          
where MainSiteId=@MainSiteId    

Update cmsMainSitePublish set           
UpdatedBy=@CreatedBy,          
UpdatedOn=GETDATE(),          
Status='I'          
where MainSiteId=@MainSiteId          
          
Select 't' ResultStatus, 'Theme Installed Successfully.' ResultMessage     
end
else
begin
Select 'f' ResultStatus, 'Theme Installation failed.' ResultMessage     
end       
end        
else      
begin      
    Select 'f' ResultStatus, 'Please Publish Theme Then Install' ResultMessage   
end      
--commit        
--end try        
--begin catch        
--Select 'f' ResultStatus, 'Exception Error' ResultMessage        
--end catch        
        
end        
        
        
GO
/****** Object:  StoredProcedure [dbo].[UpdatePublicMenuLink]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
            
CREATE Procedure [dbo].[UpdatePublicMenuLink]              
@MenuId nvarchar(100) ,              
@MenuName nvarchar(100) ,            
@PageId nvarchar(100)             
              
As              
begin              
Begin Tran              
begin try                    
begin            
if exists(select * from cmsPublicMenu where MenuName=@MenuName )            
begin            
Update cmsPublicMenu set MenuName=@MenuName,PageId=@PageId where MenuName=@MenuName --MenuId=@MenuId            
Select 't' ResultStatus, 'Menu Linked Successfully.' ResultMessage             
end            
else            
begin            
Select 'f' ResultStatus, 'Menu Link failed' ResultMessage              
end             
end            
commit              
end try              
begin catch              
Select 'f' ResultStatus, 'Exception Error' ResultMessage              
end catch              
end 
GO
/****** Object:  StoredProcedure [dbo].[UpdateUser]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
        
CREATE Procedure [dbo].[UpdateUser]            
 @Id  varchar(10)=null,        
 @UserName nvarchar (500) NULL,            
 @Email varchar(50)=null,        
 @DepartmentId varchar(100)=null,        
 @MobileNo varchar(11)=null,        
 @Role  varchar(50)=null,        
 @CreatedBy  varchar(50)=null,        
 @CIPAddress  varchar(50)=null        
        
 AS            
 if not exists(select * from ApplicationUser where Email=@Email)          
  begin          
    select 'f' ResultStatus  , 'email does not exists.' ResultMessage          
  end          
  else          
  begin          
           
 BEGIN TRAN            
 BEGIN TRY            
         
 declare @roles varchar(50)=null  
 Set @roles=(Select Role from cmsRole where RoleId=@Role)  
  
   Update ApplicationUser set       
    Role=@roles,  
    DepartmentId=@DepartmentId,  
  RoleId=@Role,      
  MobileNo=@MobileNo,      
  UserName=@UserName,      
  --Email=@Email,      
  LastUpdatedOn=GETDATE(),      
  LastUpdatedBy=@CreatedBy,      
  CurrentIPAddress =@CIPAddress      
       Where Id=@Id      
          
     select 't' ResultStatus  , 'User Updated successfull.' ResultMessage          
        
  COMMIT TRAN            
 END TRY            
 BEGIN CATCH            
 select 'f' ResultStatus  ,ERROR_MESSAGE() ResultMessage          
 END CATCH            
    end          
GO
/****** Object:  Trigger [dbo].[ActionOnApplicationUser]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create trigger [dbo].[ActionOnApplicationUser]      
on [dbo].[ApplicationUser]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into ApplicationUser_History(  
  Id,UserId,Password,DepartmentId,RoleId,Role,EmployeeId,MobileNo,UserName,Email  
      ,OfficeType,OfficeId,CreatedOn,CreatedBy,LastUpdatedOn,LastUpdatedBy,LastLoginDateTime,LastLoginIPAddress  
      ,CurrentIPAddress,CurrentLoginDateTime,isBlock,  
   ActionBy,ActionType,ActionOn  
    
  )      
  Select Id,UserId,Password,DepartmentId,RoleId,Role,EmployeeId,MobileNo,UserName,Email  
      ,OfficeType,OfficeId,CreatedOn,CreatedBy,LastUpdatedOn,LastUpdatedBy,LastLoginDateTime,LastLoginIPAddress  
      ,CurrentIPAddress,CurrentLoginDateTime,isBlock,  
  (select distinct LastUpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
  Insert Into ApplicationUser_History(  
  Id,UserId,Password,DepartmentId,RoleId,Role,EmployeeId,MobileNo,UserName,Email  
      ,OfficeType,OfficeId,CreatedOn,CreatedBy,LastUpdatedOn,LastUpdatedBy,LastLoginDateTime,LastLoginIPAddress  
      ,CurrentIPAddress,CurrentLoginDateTime,isBlock,  
   ActionBy,ActionType,ActionOn  
    
  )      
  Select Id,UserId,Password,DepartmentId,RoleId,Role,EmployeeId,MobileNo,UserName,Email  
      ,OfficeType,OfficeId,CreatedOn,CreatedBy,LastUpdatedOn,LastUpdatedBy,LastLoginDateTime,LastLoginIPAddress  
      ,CurrentIPAddress,CurrentLoginDateTime,isBlock,  
  (select distinct LastUpdatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End
GO
ALTER TABLE [dbo].[ApplicationUser] ENABLE TRIGGER [ActionOnApplicationUser]
GO
/****** Object:  Trigger [dbo].[ActionOnCareer]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create trigger [dbo].[ActionOnCareer]      
on [dbo].[cmsCareer]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsCareer_History(  
  CareerId
      ,nameOfOrganization
      ,typeOfOrganization
      ,vacancyTitle
      ,vacancyRefNo
      ,productCategory
      ,subCategory
      ,vacancyValueType
      ,vacancyValue
      ,emd
      ,documentCost
      ,vacancyType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,vacancyDocument
      ,vacancyDocument1
      ,vacancyDocument2
      ,vacancyDocument3
      ,vacancyDocument4
      ,vacancyDocument5
      ,vacancyDocument6
      ,vacancyDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,vacancyDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,createDate
      ,modifyDate
      ,status
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
      ,CreatedBy
      ,CIPAddress
      ,UpdatedBy
      ,UIPAddress,
ActionBy,  
ActionName,  
ActionOn  
  )      
  
  select   CareerId
      ,nameOfOrganization
      ,typeOfOrganization
      ,vacancyTitle
      ,vacancyRefNo
      ,productCategory
      ,subCategory
      ,vacancyValueType
      ,vacancyValue
      ,emd
      ,documentCost
      ,vacancyType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,vacancyDocument
      ,vacancyDocument1
      ,vacancyDocument2
      ,vacancyDocument3
      ,vacancyDocument4
      ,vacancyDocument5
      ,vacancyDocument6
      ,vacancyDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,vacancyDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,createDate
      ,modifyDate
      ,status
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
      ,CreatedBy
      ,CIPAddress
      ,UpdatedBy
      ,UIPAddress,  
  
  
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
   Insert Into cmsCareer_History( 
  CareerId
      ,nameOfOrganization
      ,typeOfOrganization
      ,vacancyTitle
      ,vacancyRefNo
      ,productCategory
      ,subCategory
      ,vacancyValueType
      ,vacancyValue
      ,emd
      ,documentCost
      ,vacancyType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,vacancyDocument
      ,vacancyDocument1
      ,vacancyDocument2
      ,vacancyDocument3
      ,vacancyDocument4
      ,vacancyDocument5
      ,vacancyDocument6
      ,vacancyDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,vacancyDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,createDate
      ,modifyDate
      ,status
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
      ,CreatedBy
      ,CIPAddress
      ,UpdatedBy
      ,UIPAddress,
ActionBy,  
ActionName,  
ActionOn)      
  
  select   CareerId
      ,nameOfOrganization
      ,typeOfOrganization
      ,vacancyTitle
      ,vacancyRefNo
      ,productCategory
      ,subCategory
      ,vacancyValueType
      ,vacancyValue
      ,emd
      ,documentCost
      ,vacancyType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,vacancyDocument
      ,vacancyDocument1
      ,vacancyDocument2
      ,vacancyDocument3
      ,vacancyDocument4
      ,vacancyDocument5
      ,vacancyDocument6
      ,vacancyDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,vacancyDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,createDate
      ,modifyDate
      ,status
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
      ,CreatedBy
      ,CIPAddress
      ,UpdatedBy
      ,UIPAddress,  
  
  (select distinct UpdatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End  
GO
ALTER TABLE [dbo].[cmsCareer] ENABLE TRIGGER [ActionOnCareer]
GO
/****** Object:  Trigger [dbo].[ActionOnComplainOrFeedback]    Script Date: 08-05-2021 11:59:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create trigger [dbo].[ActionOnComplainOrFeedback]      
on [dbo].[cmsCompainOrFeedback]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsComplainOrFeedback_History(  
      [ComplainId]  
      ,[ComplainType]  
      ,[ComplainSubject]  
      ,[ComplainContent]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,[ActionBy]  
      ,[ActionName]  
      ,[ActionOn])      
  
  select [ComplainId]  
      ,[ComplainType]  
      ,[ComplainSubject]  
      ,[ComplainContent]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],  
       
  
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
   Insert Into cmsComplainOrFeedback_History(  
     [ComplainId]  
      ,[ComplainType]  
      ,[ComplainSubject]  
      ,[ComplainContent]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,[ActionBy]  
      ,[ActionName]  
      ,[ActionOn])      
  
  select [ComplainId]  
      ,[ComplainType]  
      ,[ComplainSubject]  
      ,[ComplainContent]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
     ,  
  
  (select distinct UpdatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End  
GO
ALTER TABLE [dbo].[cmsCompainOrFeedback] ENABLE TRIGGER [ActionOnComplainOrFeedback]
GO
/****** Object:  Trigger [dbo].[ActionOnDepartment]    Script Date: 08-05-2021 11:59:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
Create trigger [dbo].[ActionOnDepartment]      
on [dbo].[cmsDepartment]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsDepartment_History(  
        [DepartmentId]  
      ,[DepartmentType]  
      ,[DepartmentName]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,[ActionBy]  
      ,[ActionName]  
      ,[ActionOn])      
  
  select  [DepartmentId]  
      ,[DepartmentType]  
      ,[DepartmentName]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,  
        
  
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
   Insert Into cmsDepartment_History(  
       [DepartmentId]  
      ,[DepartmentType]  
      ,[DepartmentName]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,[ActionBy]  
      ,[ActionName]  
      ,[ActionOn])      
  
  select  [DepartmentId]  
      ,[DepartmentType]  
      ,[DepartmentName]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],  
  
  (select distinct UpdatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End  
GO
ALTER TABLE [dbo].[cmsDepartment] ENABLE TRIGGER [ActionOnDepartment]
GO
/****** Object:  Trigger [dbo].[ActionOnFAQ]    Script Date: 08-05-2021 11:59:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[ActionOnFAQ]      
on [dbo].[cmsFaQ]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsFAQ_History(  
       [FaqId]  
      ,[QuestionCategoryhindi]  
      ,[QuestionCategory]  
      ,[QuestionHindi]  
      ,[Question]  
      ,[AnswerHindi]  
      ,[Answer]  
      ,[AnswerDate]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,[ActionBy]  
      ,[ActionName]  
      ,[ActionOn])      
  
  select [FaqId]  
      ,[QuestionCategoryhindi]  
      ,[QuestionCategory]  
      ,[QuestionHindi]  
      ,[Question]  
      ,[AnswerHindi]  
      ,[Answer]  
      ,[AnswerDate]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,  
        
  
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
   Insert Into cmsFAQ_History(  
      [FaqId]  
      ,[QuestionCategoryhindi]  
      ,[QuestionCategory]  
      ,[QuestionHindi]  
      ,[Question]  
      ,[AnswerHindi]  
      ,[Answer]  
      ,[AnswerDate]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,[ActionBy]  
      ,[ActionName]  
      ,[ActionOn])      
  
  select [FaqId]  
      ,[QuestionCategoryhindi]  
      ,[QuestionCategory]  
      ,[QuestionHindi]  
      ,[Question]  
      ,[AnswerHindi]  
      ,[Answer]  
      ,[AnswerDate]  
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],  
  
  (select distinct UpdatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End  
GO
ALTER TABLE [dbo].[cmsFaQ] ENABLE TRIGGER [ActionOnFAQ]
GO
/****** Object:  Trigger [dbo].[ActionOnMediaGallery]    Script Date: 08-05-2021 11:59:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger [dbo].[ActionOnMediaGallery]      
on [dbo].[cmsMediaGallery]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsMediaGallery_History(  
       [MediaId]  
      ,[MediaType]  
      ,[MediaTitle]  
      ,[MediaContent]  
      ,[MediaPath]  
	  ,[FileSize]
	  ,[Version]
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],[ActionBy],[ActionName],[ActionOn])      
  
  select [MediaId]  
      ,[MediaType]  
      ,[MediaTitle]  
      ,[MediaContent]  
      ,[MediaPath]  
	  ,[FileSize]
	  ,[Version]
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],  
  
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
   Insert Into cmsMediaGallery_History([MediaId]  
      ,[MediaType]  
      ,[MediaTitle]  
      ,[MediaContent]  
      ,[MediaPath]  
	  ,[FileSize]
	  ,[Version]
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],[ActionBy],[ActionName],[ActionOn])      
  
  select [MediaId]  
      ,[MediaType]  
      ,[MediaTitle]  
      ,[MediaContent]  
      ,[MediaPath]  
	  ,[FileSize]
	  ,[Version]
      ,[Status]  
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],  
  
  (select distinct UpdatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End
GO
ALTER TABLE [dbo].[cmsMediaGallery] ENABLE TRIGGER [ActionOnMediaGallery]
GO
/****** Object:  Trigger [dbo].[ActionOnNotification]    Script Date: 08-05-2021 11:59:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[ActionOnNotification]      
on [dbo].[cmsNotification]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsNotification_History(  
        [NotificationId]  
      ,[Description],DescriptionHindi  
  , ExpiryDate  
  ,StartDate  
      ,[Status]  
	  ,Type, PageId,Path,LinkType,Target,Priority,NewGIF
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,[ActionBy]  
      ,[ActionName]  
      ,[ActionOn])      
  
  select  [NotificationId]  
      ,[Description],DescriptionHindi  
   ,ExpiryDate  
    ,StartDate  
      ,[Status]  
	   ,Type, PageId,Path,LinkType,Target,Priority,NewGIF
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],  
        
  
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
   Insert Into cmsNotification_History(  
       [NotificationId]  
      ,[Description],DescriptionHindi  
   ,ExpiryDate  
    ,StartDate  
      ,[Status]  
	   ,Type, PageId,Path,LinkType,Target,Priority,NewGIF
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress]  
      ,[ActionBy]  
      ,[ActionName]  
      ,[ActionOn])      
  
  select  [NotificationId]  
      ,[Description],DescriptionHindi  
   ,ExpiryDate  
    ,StartDate  
      ,[Status]  
	   ,Type, PageId,Path,LinkType,Target,Priority,NewGIF
      ,[CreatedBy]  
      ,[CreatedOn]  
      ,[CIPAddress]  
      ,[UpdatedBy]  
      ,[UpdatedOn]  
      ,[UIPAddress],  
  
  (select distinct UpdatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End
GO
ALTER TABLE [dbo].[cmsNotification] ENABLE TRIGGER [ActionOnNotification]
GO
/****** Object:  Trigger [dbo].[ActionOnPages]    Script Date: 08-05-2021 11:59:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[ActionOnPages]      
on [dbo].[cmsPages]      
After  Update ,Delete
As      
begin      
 SET NOCOUNT ON;       
              
       

 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsPagesHistory(  
  PageId,  
  DepartmentId,  
  MetaTitle,  
  MetaContent,  
PageContent,  
PageName,  
PageTitle,  
PageContentHindi,  
PageNameHindi,  
PageTitleHindi,  
ContentModifyStatus,  
Status,  
CreatedOn,  
CreatedBy,CIPAddress,  
UpdatedBy,  
UpdatedOn,  
UIPAddress,  
ActionBy,  
ActionName,  
ActionOn  
  )      
  
  select   PageId,  
  DepartmentId, MetaTitle,  
  MetaContent,  
PageContent,  
PageName,  
PageTitle,  
PageContentHindi,  
PageNameHindi,  
PageTitleHindi,  
ContentModifyStatus,  
Status,  
CreatedOn,  
CreatedBy,CIPAddress,  
UpdatedBy,  
UpdatedOn,  
UIPAddress,  
  
  
  (select distinct UpdatedBy from inserted),'Updated',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
   Insert Into cmsPagesHistory(  PageId,  
  DepartmentId,  
   MetaTitle,  
  MetaContent,  
PageContent,  
PageName,  
PageTitle,  
PageContentHindi,  
PageNameHindi,  
PageTitleHindi,  
ContentModifyStatus,  
Status,  
CreatedOn,  
CreatedBy,CIPAddress,  
UpdatedBy,  
UpdatedOn,  
UIPAddress,  
ActionBy,  
ActionName,  
ActionOn)      
  
  select   PageId,  
  DepartmentId,  
   MetaTitle,  
  MetaContent,  
PageContent,  
PageName,  
PageTitle,  
PageContentHindi,  
PageNameHindi,  
PageTitleHindi,  
ContentModifyStatus,  
Status,  
CreatedOn,CreatedBy,CIPAddress,  
UpdatedBy,  
UpdatedOn,  
UIPAddress,  
  
  (select distinct UpdatedBy from inserted),'Deleted',getdate()  from Deleted      
end  
   
      
 end      
   
      
GO
ALTER TABLE [dbo].[cmsPages] ENABLE TRIGGER [ActionOnPages]
GO
/****** Object:  Trigger [dbo].[ActionOnPublicMenu]    Script Date: 08-05-2021 11:59:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[ActionOnPublicMenu]      
on [dbo].[cmsPublicMenu]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsPublicMenu_History(  
       MenuId  
      ,ModuleId  
      ,MenuName  
      ,MenuNameHindi  
      ,ParentId  
      ,PageId  
      ,Status  
      ,Priority  
	  ,LinkType
	  ,Path
	  ,Target
      ,CreatedBy  
      ,CreatedOn  
      ,CIPAddress  
      ,UpdatedBy  
      ,UpdatedOn  
      ,UIPAddress  
      ,ActionBy  
      ,ActionName  
      ,ActionOn  
  )      
  
  select MenuId  
      ,ModuleId  
      ,MenuName  
      ,MenuNameHindi  
      ,ParentId  
      ,PageId  
      ,Status  
      ,Priority  
	  ,LinkType
	  ,Path
	  ,Target
      ,CreatedBy  
      ,CreatedOn  
      ,CIPAddress  
      ,UpdatedBy  
      ,UpdatedOn  
      ,UIPAddress,  
  
  (select distinct UpdatedBy from inserted),'Updated',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
  Insert Into cmsPublicMenu_History(  
       MenuId  
      ,ModuleId  
      ,MenuName  
      ,MenuNameHindi  
      ,ParentId  
      ,PageId  
      ,Status  
      ,Priority  
	  ,LinkType
	  ,Path
	  ,Target
      ,CreatedBy  
      ,CreatedOn  
      ,CIPAddress  
      ,UpdatedBy  
      ,UpdatedOn  
      ,UIPAddress  
      ,ActionBy  
      ,ActionName  
      ,ActionOn  
  )      
  
  select MenuId  
      ,ModuleId  
      ,MenuName  
      ,MenuNameHindi  
      ,ParentId  
      ,PageId  
      ,Status  
      ,Priority  
	  ,LinkType
	  ,Path
	  ,Target
      ,CreatedBy  
      ,CreatedOn  
      ,CIPAddress  
      ,UpdatedBy  
      ,UpdatedOn  
      ,UIPAddress,  
  
  (select distinct UpdatedBy from inserted),'Deleted',getdate()  from Deleted      
end  
   
      
 end      
   
      
End
GO
ALTER TABLE [dbo].[cmsPublicMenu] ENABLE TRIGGER [ActionOnPublicMenu]
GO
/****** Object:  Trigger [dbo].[ActionOnSection]    Script Date: 08-05-2021 11:59:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
Create trigger [dbo].[ActionOnSection]      
on [dbo].[cmsSection]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsSectionHistory([SectionId],[PageId],[SectionContent],[SectionName],[SectionTitle],[Status],[UpdatedBy],[UpdatedOn],[UIPAddress],[ActionBy],[ActionName],[ActionOn])      
  
  select [SectionId],[PageId],[SectionContent],[SectionName],[SectionTitle],[Status],[UpdatedBy],[UpdatedOn],[UIPAddress],  
  
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
   Insert Into cmsSectionHistory([SectionId],[PageId],[SectionContent],[SectionName],[SectionTitle],[Status],[UpdatedBy],[UpdatedOn],[UIPAddress],[ActionBy],[ActionName],[ActionOn])      
  
  select [SectionId],[PageId],[SectionContent],[SectionName],[SectionTitle],[Status],[UpdatedBy],[UpdatedOn],[UIPAddress],  
  
  (select distinct UpdatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End  
GO
ALTER TABLE [dbo].[cmsSection] ENABLE TRIGGER [ActionOnSection]
GO
/****** Object:  Trigger [dbo].[ActionOnTenderCategory]    Script Date: 08-05-2021 11:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[ActionOnTenderCategory]      
on [dbo].[cmsTenderCategory]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsTenderCategoryHistory([CategoryId]  ,[CategoryName] ,[CreatedBy],[CreatedOn],[CIPAddress],[UpdatedBy],[UpdatedOn],[UIPAddress],[ActionBy],[ActionName],[ActionOn])      
  select [CategoryId]  ,[CategoryName] ,[CreatedBy],[CreatedOn],[CIPAddress],[UpdatedBy],[UpdatedOn],[UIPAddress] ,    
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
    Insert Into cmsTenderCategoryHistory([CategoryId]  ,[CategoryName] ,[CreatedBy],[CreatedOn],[CIPAddress],[UpdatedBy],[UpdatedOn],[UIPAddress],[ActionBy],[ActionName],[ActionOn])      
  select [CategoryId]  ,[CategoryName] ,[CreatedBy],[CreatedOn],[CIPAddress],[UpdatedBy],[UpdatedOn],[UIPAddress] ,    
  (select distinct CreatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End  
GO
ALTER TABLE [dbo].[cmsTenderCategory] ENABLE TRIGGER [ActionOnTenderCategory]
GO
/****** Object:  Trigger [dbo].[ActionOnTenders]    Script Date: 08-05-2021 11:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [dbo].[ActionOnTenders]      
on [dbo].[cmsTenders]      
After Update ,Delete  
As      
begin      
 SET NOCOUNT ON;       
              
       
 begin      
 if exists(SELECT * from inserted) and exists (SELECT * from deleted)  
begin  
  Insert Into cmsTenderHistroy(
tenderId
      ,nameOfOrganization
      ,typeOfOrganization
      ,tenderTitle
      ,tenderRefNo
      ,productCategory
      ,subCategory
      ,tenderValueType
      ,tenderValue
      ,emd
      ,documentCost
      ,tenderType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,tenderDocument
      ,tenderDocument1
      ,tenderDocument2
      ,tenderDocument3
      ,tenderDocument4
      ,tenderDocument5
      ,tenderDocument6
      ,tenderDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,tenderDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,createDate
      ,modifyDate
      ,ExpiryDate
      ,PublishedDate
      ,status
	  ,UnderEvaluation
       ,LastDateOfEvaluation
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
      ,CreatedBy
      ,CIPAddress
      ,UpdatedBy
      ,UIPAddress,
	  [ActionBy],
	  [ActionName],
	  [ActionOn])      
  
  select tenderId
      ,nameOfOrganization
      ,typeOfOrganization
      ,tenderTitle
      ,tenderRefNo
      ,productCategory
      ,subCategory
      ,tenderValueType
      ,tenderValue
      ,emd
      ,documentCost
      ,tenderType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,tenderDocument
      ,tenderDocument1
      ,tenderDocument2
      ,tenderDocument3
      ,tenderDocument4
      ,tenderDocument5
      ,tenderDocument6
      ,tenderDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,tenderDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,createDate
      ,modifyDate
      ,ExpiryDate
      ,PublishedDate
      ,status
	  ,UnderEvaluation
      ,LastDateOfEvaluation
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
      ,CreatedBy
      ,CIPAddress
      ,UpdatedBy
      ,UIPAddress,  
  (select distinct UpdatedBy from inserted),'Update',getdate()  from Deleted      
end  
  
  
If exists(select * from deleted) and not exists(Select * from inserted)  
begin   
    Insert Into cmsTenderHistroy(
	tenderId
      ,nameOfOrganization
      ,typeOfOrganization
      ,tenderTitle
      ,tenderRefNo
      ,productCategory
      ,subCategory
      ,tenderValueType
      ,tenderValue
      ,emd
      ,documentCost
      ,tenderType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,tenderDocument
      ,tenderDocument1
      ,tenderDocument2
      ,tenderDocument3
      ,tenderDocument4
      ,tenderDocument5
      ,tenderDocument6
      ,tenderDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,tenderDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
    ,createDate
      ,modifyDate
      ,ExpiryDate
      ,PublishedDate
      ,status
	  ,UnderEvaluation
      ,LastDateOfEvaluation
 ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
      ,CreatedBy
      ,CIPAddress
      ,UpdatedBy
      ,UIPAddress,[ActionBy],[ActionName],[ActionOn])      
  select tenderId
      ,nameOfOrganization
      ,typeOfOrganization
      ,tenderTitle
      ,tenderRefNo
      ,productCategory
      ,subCategory
      ,tenderValueType
      ,tenderValue
      ,emd
      ,documentCost
      ,tenderType
      ,biddingType
      ,limited
      ,location
      ,firstAnnouncementDate
      ,lastDateOfCollection
      ,lastDateForSubmission
      ,openingDate
      ,workDescription
      ,preQualification
      ,preBidMeet
      ,tenderDocument
      ,tenderDocument1
      ,tenderDocument2
      ,tenderDocument3
      ,tenderDocument4
      ,tenderDocument5
      ,tenderDocument6
      ,tenderDocument7
      ,extradoc
      ,extradoc1
      ,extradoc2
      ,tenderDocumentExtra
      ,hindiDocs
      ,linkName
      ,linkName1
      ,linkName2
      ,linkName3
      ,linkName4
      ,format1
      ,format2
      ,format3
      ,format4
      ,format5
      ,createDate
      ,modifyDate
      ,ExpiryDate
      ,PublishedDate
      ,status
	  ,UnderEvaluation
      ,LastDateOfEvaluation
      ,depName
      ,recievingDate
      ,assignTo
      ,descriptionOfAssign
      ,CreatedBy
      ,CIPAddress
      ,UpdatedBy
      ,UIPAddress,  
  (select distinct CreatedBy from inserted),'Delete',getdate()  from Deleted      
end  
   
      
 end      
   
      
End
GO
ALTER TABLE [dbo].[cmsTenders] ENABLE TRIGGER [ActionOnTenders]
GO
