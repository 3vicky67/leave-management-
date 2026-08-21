@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Request Interface View'
define root view entity ZI_Leave
  as select from zleave_req_db
  association [0..1] to zemployee_db as _Employee on $projection.EmpId = _Employee.emp_id
{
  key req_id as ReqId,
  emp_id as EmpId,
  _Employee.emp_name as EmpName,
  start_date as StartDate,
  end_date as EndDate,
  total_days as TotalDays,
  reason as Reason,
  Status,
  
  // Add this calculation for the UI color
  case Status
    when 'A' then 3 
    when 'R' then 1 
    when 'P' then 2 
    else 0          
  end as StatusCriticality,
  
  // --- IMAGE FIELDS SPLIT ---
  @Semantics.imageUrl: true
  image_url as ImageUrl,
  image_url as ImageUrlInput, 
  
  department as Department,
  
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,

  _Employee
}
