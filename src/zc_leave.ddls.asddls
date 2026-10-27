@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Leave Request'
@Metadata.allowExtensions: true 
@Search.searchable: true
define root view entity ZC_LEAVE
  provider contract transactional_query
  as projection on ZI_Leave
{
  key ReqId,
  
  @Search.defaultSearchElement: true
  @EndUserText.label: 'Employee ID'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCEmployee', element: 'EmpId' } }]
  EmpId,
  
  @Search.defaultSearchElement: true
  @EndUserText.label: 'Employee Name'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCEmployee', element: 'EmpName' } }]
  EmpName,
  
  // --- IMAGE FIELDS ADDED ---
  @EndUserText.label: 'Photo'
  ImageUrl,
  
  @EndUserText.label: 'Paste Image URL'
  ImageUrlInput,
  
  // --- DEPARTMENT ADDED WITH VALUE HELP ---
  @EndUserText.label: 'Department'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCEmployee', element: 'Department' } }]
  Department,
  
  @EndUserText.label: 'Start Date'
  StartDate,
  
  @EndUserText.label: 'End Date'
  EndDate,
  
  @EndUserText.label: 'Total Days'
  TotalDays,
  
  @EndUserText.label: 'Leave Reason'
  Reason,
  
  @EndUserText.label: 'Balance Days'
  BalanceDays,
  
  @EndUserText.label: 'Approval Status'
  Status,
  StatusCriticality,
  CreatedAt,
  LocalLastChangedAt
}
