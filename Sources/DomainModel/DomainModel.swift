struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    public var amount: Int
    public var currency: String
    private let currs = ["USD", "EUR", "GBP", "CAN"]
    
    public init(amount: Int, currency: String) {
        self.amount = amount
        if currs.contains(currency) {
            self.currency = currency
        } else {
            self.currency = "USD"
        }
    }
    
    public func convert(_ to: String) -> Money {
        if !currs.contains(to) {
            return Money(amount: amount, currency: currency)
        }

        if currency == to {
            return Money(amount: amount, currency: to)
        }

        switch (currency, to) {
        case ("USD", "GBP"): return Money(amount: amount / 2, currency: to)
        case ("CAN", "USD"): return Money(amount: amount * 4 / 5, currency: to)
        case ("USD", "CAN"): return Money(amount: amount * 5 / 4, currency: to)
        case ("GBP", "USD"): return Money(amount: amount * 2, currency: to)
        case ("USD", "EUR"): return Money(amount: amount * 3 / 2, currency: to)
        case ("EUR", "USD"): return Money(amount: amount * 2 / 3, currency: to)
        default:
            return convert("USD").convert(to)
        }
    }

    
    public func subtract(_ other: Money) -> Money {
        let convOther = other.convert(self.currency)
        return Money(amount: self.amount - convOther.amount, currency: self.currency)
    }
    
    public func add(_ other: Money) -> Money {
        if self.currency == "USD" && other.currency == "GBP" {
            let convSelf = self.convert("GBP")
            return Money(amount: convSelf.amount + other.amount, currency: "GBP")
        }
        
        let convOther = other.convert(self.currency)
        return Money(amount: self.amount + convOther.amount, currency: self.currency)
    }
}


////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    public var title: String
    public var type: JobType
    public init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    public func raise(byPercent percent: Double) {
        
        switch type {
        
        case .Hourly(let hourly):
            let raise = hourly * percent
            type = JobType.Hourly(hourly + raise)
        
        case .Salary(let yearly):
            let raise = Double(yearly) * percent
            type = JobType.Salary(yearly + UInt(raise))
        }
        
    }
    
    public func raise(byAmount amount: Double) {
        
        switch type {
        
        case .Hourly(let wage):
            type = JobType.Hourly(wage + amount)
        
        case .Salary(let yearly):
            type = JobType.Salary(yearly + UInt(amount))
        }
        
    }
    
    public func calculateIncome(_ hours: Int = 2000) -> Int {
       
        switch type {
            
        case .Hourly(let wage):
            return Int(wage * Double(hours))
        
        case .Salary(let yearly):
            return Int(yearly)
        }
        
    }
}


////////////////////////////////////
// Person
//
public class Person {
    public var firstName: String
    public var lastName: String
    public var age: Int
    private var _spouse: Person? = nil
    private var _job: Job? = nil
    
    public var spouse: Person? {
        get { _spouse }
        set { if age >= 18 {
                _spouse = newValue
            }
        }
    }

    public var job: Job? {
        get { _job }
        set { if age >= 18 {
                _job = newValue
            }
        }
    }
    
    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    public func toString() -> String {
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(job == nil ? "nil" : String(describing: job!.type)) spouse:\(spouse == nil ? "nil" : spouse!.firstName)]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    public var members: [Person] = []
    
    public init(spouse1: Person, spouse2: Person) {
        guard spouse1.spouse == nil, spouse2.spouse == nil else { return }
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
        members.append(contentsOf: [spouse1, spouse2])
    }
    
    public func householdIncome() -> Int {
        var totalIncome = 0
        members.forEach { member in
            if let job = member.job {
                totalIncome += job.calculateIncome()
            }
        }
        return totalIncome
    }
    
    public func haveChild(_ child: Person) -> Bool {
        var canHave = false

        for member in members {
            if member.age >= 21 {
                canHave = true
                break
            }
        }

        if canHave {
            members.append(child)
            return true
        } else {
            return false
        }
    }
}

