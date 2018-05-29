import UIKit

// to get the nearest weekend date - forward or backward
extension Date {
    static func totalNumberOfWeeksRoundOffByWeekends(From fromDate: TimeInterval, To toDate: TimeInterval) -> (stringRep: [(from: String, to: String)], millis: [(from: TimeInterval, to: TimeInterval)]){
        
        let previousWeeken = Date(timeIntervalSince1970: fromDate).previous(.monday)
        let nextWeekend = Date(timeIntervalSince1970: toDate).next(.sunday)
        
        var stringRep: [(from: String, to: String)] = []
        var millis: [(from: TimeInterval, to: TimeInterval)] = []
        
        let weekInMilliseconds: Double = 604800000
        var fromdate = previousWeeken.timeIntervalSince1970
        let to = nextWeekend.timeIntervalSince1970
//        var fromdate = fromDate
//        let to = toDate
         while fromdate < to {
            let monthAndDateFrom = Date.dateAndMonthFormat(Date: Date(timeIntervalSince1970: fromdate/1000))
            // this is subratcted by 86400000 to display the dates like 17-23 24-31
            let toDAte = (Date(timeIntervalSince1970: (fromdate + weekInMilliseconds - 86400000) / 1000))
            let monthAndDateTo = Date.dateAndMonthFormat(Date: toDAte)
            let nowOrDate: String = (toDAte.timeIntervalSince1970 < Date().timeIntervalSince1970 ? (monthAndDateTo.month + " " + monthAndDateTo.date): "Today")
            stringRep.append((from: (monthAndDateFrom.month + " " + monthAndDateFrom.date), to: nowOrDate))
            // here it is not subracted by 86400000 as to load the words values for that day also
            millis.append((from: fromdate, to: fromdate + weekInMilliseconds))
            fromdate += weekInMilliseconds
        }
        
        return (stringRep.reversed(), millis.reversed())
    }
    
   static func totalNumberOfWeeks(From fromDate: TimeInterval, To toDate: TimeInterval) -> Int {
        var count = 0
        let weekInMilliseconds: Double = 604800000
        var from = fromDate
        while fromDate <= toDate {
            count += 1
            from += weekInMilliseconds
            print(Date(timeIntervalSince1970: from/1000))
        }
        return count
    }
    static func dateAndMonthFormat(Date date: Date) -> (month: String, date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let stringMonth = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "dd"
        let stringDate = dateFormatter.string(from: date)
        return (stringMonth, stringDate)
    }
    
    static func today() -> Date {
        return Date()
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.index(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
}

// MARK: Helper methods
extension Date {
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .Next:
                return .forward
            case .Previous:
                return .backward
            }
        }
    }
}

class HelperFunctionsAndExtensions: NSObject {

}
