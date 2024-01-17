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

  }

  protected override AfterInsert(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

  }

  protected override BeforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

  }

  protected override AfterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {

  }

  protected override BeforeDelete(Map<Id, SObject> oldMap) {

  }

  protected override AfterDelete(Map<Id, SObject> oldMap) {

  }

  protected override AfterUndelete(Map<Id, SObject> oldMap) {
    
  }
}
```
