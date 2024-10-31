@IsTest
public class TriggerHandlerTest {
  static Integer count = 5;

  @TestSetup
  static void testSetup() {
    Account acc = new Account();
    acc.Name = 'Test Account';
    insert acc;
  }

  @IsTest
  static void testInsert() {
    Test.startTest();
    Account acc = new Account();
    acc.Name = 'triggerHandler';
    insert acc;
    Test.stopTest();
    System.assertNotEquals(
      null,
      acc.Id,
      'Account should have been inserted into the database and an Id set'
    );
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Account WHERE Name = 'triggerHandler'],
      'Account should have been inserted into the database'
    );
  }

  @IsTest
  static void testUpdate() {
    List<Account> accounts = [SELECT Id, Name FROM Account];
    Test.startTest();
    for (Account acc : accounts) {
      acc.Name = 'triggerHandlerUpdate';
    }
    update accounts;
    Test.stopTest();
    List<Account> updatedAccounts = [SELECT Id, Name FROM Account];
    System.assertEquals(
      count,
      updatedAccounts.size(),
      'Updated accounts should equal the number of test setup accounts'
    );
    for (Account acc : updatedAccounts) {
      System.assertEquals(
        'triggerHandlerUpdate',
        acc.Name,
        'Account name must be updated'
      );
    }
  }

  @IsTest
  static void testDeleteUndelete() {
    List<Account> accounts = [SELECT Id FROM Account];
    Test.startTest();
    delete accounts;
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Account],
      'Accounts must be deleted'
    );
    undelete accounts;
    Test.stopTest();
    System.assertEquals(
      count,
      [SELECT COUNT() FROM Account],
      'Accounts must be undeleted'
    );
  }

  // @IsTest
  // static void testDisabled() {
  // 	Test.startTest();
  // 	AccountTriggerHandler.triggerDisabled = true;
  // 	Account acc = new Account();
  // 	acc.Name = 'triggerDisabled';
  // 	acc.Phone = '1234567890';
  // 	insert acc;
  // 	Test.stopTest();
  // 	System.assertEquals('1234567890', [SELECT Phone FROM Account WHERE Name = 'triggerDisabled' LIMIT 1].Phone, 'Account phone should not have been formatted');
  // }

  @IsTest
  static void testParameterError() {
    Test.startTest();
    try {
      new TriggerHandler();
      System.assert(false, 'Expected an exception');
    } catch (TriggerException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  // @IsTest
  // static void testUowSuccess() {
  // 	Account acc = [SELECT Id FROM Account LIMIT 1];
  // 	Test.startTest();
  // 	new LeadFactory().buildAndInsert();
  // 	new QuoteFactory().buildAndInsert();
  // 	Test.stopTest();
  // 	System.assertEquals(1, [SELECT Count() FROM Lead], 'Leads should have been inserted into the database');
  // 	System.assertEquals(1, [SELECT Count() FROM Quote], 'Quotes should have been inserted into the database');
  // }

  @IsTest
  static void testUowError() {
    Test.startTest();
    try {
      Account acc = new Account();
      acc.Name = null;
      System.assert(false, 'Expected an exception');
    } catch (Exception e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Account],
      'Accounts should not have been inserted into the database'
    );
  }
}
