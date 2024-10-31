/**
 * Created on Oct 13 2020
 *
 * Copyright (c) 2020 MJ12358
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *    are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * - Neither the name of the company, software or the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 *  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, TORT (INCLUDING NEGLIGENCE) OR OTHERWISE,
 *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE USE OF THIS SOFTWARE OR OTHER DEALINGS IN THE SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

public virtual without sharing class TriggerHandler {
  private List<SObject> sObjectList;
  protected Schema.SObjectType sObjectType;
  protected SObjectUnitOfWork uow;
  protected Trigger_Setting__mdt setting {
    get {
      if (setting == null) {
        try {
          setting = [
            SELECT
              IsDisabled__c,
              BeforeInsert__c,
              BeforeUpdate__c,
              BeforeDelete__c,
              AfterInsert__c,
              AfterUpdate__c,
              AfterDelete__c,
              AfterUndelete__c
            FROM Trigger_Setting__mdt
            WHERE MasterLabel = :this.sObjectType.getDescribe().getName()
            LIMIT 1
          ];
        } catch (Exception e) {
          throw new TriggerException(
            String.format(
              System.Label.Trigger_SettingException,
              new List<Object>{ this.sObjectType }
            )
          );
        }
      }
      return setting;
    }
    private set;
  }

  @TestVisible
  protected TriggerHandler() {
    if (!Trigger.isExecuting && !Test.isRunningTest()) {
      throw new TriggerException(System.Label.Trigger_ContextException);
    }
    if (Trigger.new == null && Trigger.old == null) {
      throw new TriggerException(System.Label.Trigger_ParameterException);
    }
    if (Trigger.new != null) {
      this.sObjectList = Trigger.new;
      this.sObjectType = Trigger.new.getSObjectType();
    } else {
      this.sObjectList = Trigger.old;
      this.sObjectType = Trigger.old.getSObjectType();
    }
  }

  public void Run() {
    System.debug(
      String.format(
        System.Label.Trigger_Info,
        new List<Object>{
          this.sObjectType,
          Trigger.OperationType,
          Trigger.size
        }
      )
    );

    if (this.setting.IsDisabled__c || IsDisabled()) {
      System.debug(
        String.format(
          System.Label.Trigger_Disabled,
          new List<Object>{ this.sObjectType }
        )
      );
      return;
    }

    switch on Trigger.OperationType {
      when BEFORE_INSERT {
        if (!this.setting.BeforeInsert__c) {
          logEventDisabled();
          return;
        }
        handleBeforeInsert(Trigger.new);
      }
      when BEFORE_UPDATE {
        if (!this.setting.BeforeUpdate__c) {
          logEventDisabled();
          return;
        }
        handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
      }
      when BEFORE_DELETE {
        if (!this.setting.BeforeDelete__c) {
          logEventDisabled();
          return;
        }
        handleBeforeDelete(Trigger.oldMap);
      }
      when AFTER_INSERT {
        if (!this.setting.AfterInsert__c) {
          logEventDisabled();
          return;
        }
        handleAfterInsert(Trigger.newMap);
      }
      when AFTER_UPDATE {
        if (!this.setting.AfterUpdate__c) {
          logEventDisabled();
          return;
        }
        handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
      }
      when AFTER_DELETE {
        if (!this.setting.AfterDelete__c) {
          logEventDisabled();
          return;
        }
        handleAfterDelete(Trigger.oldMap);
      }
      when AFTER_UNDELETE {
        if (!this.setting.AfterUndelete__c) {
          logEventDisabled();
          return;
        }
        handleAfterUndelete(Trigger.oldMap);
      }
    }
    finish();
  }

  private void finish() {
    if (this.uow == null) {
      return;
    }
    try {
      this.uow.commitWork();
    } catch (Exception e) {
      this.sObjectList[0].addError(formatErrorMessage(e));
    }
  }

  //* Handler methods

  private void handleBeforeInsert(List<SObject> newList) {
    ValidateInsert(newList);
    ApplyDefaults(newList);
    BeforeInsert(newList);
  }

  private void handleBeforeUpdate(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
    ValidateUpdate(newMap, oldMap);
    ApplyDefaults(newMap, oldMap);
    BeforeUpdate(newMap, oldMap);
  }

  private void handleBeforeDelete(Map<Id, SObject> oldMap) {
    ValidateDelete(oldMap);
    BeforeDelete(oldMap);
  }

  private void handleAfterInsert(Map<Id, SObject> newMap) {
    AfterInsert(newMap);
  }

  private void handleAfterUpdate(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
    AfterUpdate(newMap, oldMap);
  }

  private void handleAfterDelete(Map<Id, SObject> oldMap) {
    AfterDelete(oldMap);
  }

  private void handleAfterUndelete(Map<Id, SObject> oldMap) {
    AfterUndelete(oldMap);
  }

  //* Overridable methods

  protected virtual Boolean IsDisabled() {
    return false;
  }

  protected virtual void ApplyDefaults(List<SObject> newList) {
    // on insert
  }

  protected virtual void ApplyDefaults(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
    // on update
  }

  protected virtual void BeforeInsert(List<SObject> newList) {
  }

  protected virtual void BeforeUpdate(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
  }

  protected virtual void BeforeDelete(Map<Id, SObject> oldMap) {
  }

  protected virtual void AfterInsert(Map<Id, SObject> newMap) {
  }

  protected virtual void AfterUpdate(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
  }

  protected virtual void AfterDelete(Map<Id, SObject> oldMap) {
  }

  protected virtual void AfterUndelete(Map<Id, SObject> oldMap) {
  }

  protected virtual void ValidateInsert(List<SObject> newList) {
    // ISNEW() in formula
  }

  protected virtual void ValidateUpdate(
    Map<Id, SObject> newMap,
    Map<Id, SObject> oldMap
  ) {
    // ISCHANGED() in formula
  }

  protected virtual void ValidateDelete(Map<Id, SObject> oldMap) {
  }

  //* Utility methods

  private void logEventDisabled() {
    System.debug(
      String.format(
        System.Label.Trigger_EventDisabled,
        new List<Object>{ this.sObjectType, Trigger.OperationType }
      )
    );
  }

  private String formatErrorMessage(Exception e) {
    if (e.getMessage().contains('VALIDATION_EXCEPTION')) {
      return e.getMessage().split('VALIDATION_EXCEPTION')[1];
    }
    return e.getMessage();
  }
}
