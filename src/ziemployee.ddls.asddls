@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'to know about leave'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ziemployee as select from zemployee_db
{
    key emp_id as EmpId,
    emp_name as EmpName,
    department as Department,
    leave_balance as LeaveBalance,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt
}
