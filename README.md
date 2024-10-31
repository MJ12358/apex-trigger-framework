# apex-trigger-framework

## Requirements

- This package requires `SObjectUnitOfWork`.
- This can be used from either [fflib](https://github.com/financialforcedev/df12-apex-enterprise-patterns/blob/master/df12/src/classes/SObjectUnitOfWork.cls) or from my [SObjectUtils](https://github.com/MJ12358/apex-sobject-utils)

## Usage

```apex
public class AccountTrigger extends TriggerHandler {
  static Boolean isDisabled = false;

  public AccountTrigger() {
    this.uow = new SObjectUnitOfWork();
  }

  protected override IsDisabled() {
    return isDisabled;
  }

  protected override BeforeInsert(List<SObject> newList) {
    // Do work "Before Insert".
  }

  protected override AfterInsert(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
    // Do work "After Insert".
  }

  protected override BeforeUpdate(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
    // Do work "Before Update".
  }

  protected override AfterUpdate(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
    // Do work "After Update".
  }

  protected override BeforeDelete(Map<Id, SObject> oldMap) {
    // Do work "Before Delete".
  }

  protected override AfterDelete(Map<Id, SObject> oldMap) {
    // Do work "After Delete".
  }

  protected override AfterUndelete(Map<Id, SObject> oldMap) {
    // Do work "After Undelete".
  }
}
```
