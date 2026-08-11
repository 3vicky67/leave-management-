@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Employee'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZCEmployee
  provider contract transactional_query   // <--- ADD THIS LINE BACK
  as projection on ziemployee
{
  
  @Search.defaultSearchElement: true
  key EmpId,
  
  @Search.defaultSearchElement: true
  EmpName,
  
  Department,
  LeaveBalance
}
