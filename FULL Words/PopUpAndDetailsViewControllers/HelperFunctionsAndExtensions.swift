import UIKit

// to get the nearest weekend date - forward or backward
extension Date {
    static func totalNumberOfWeeksRoundOffByWeekends(From fromDate: TimeInterval, To toDate: TimeInterval) -> (stringRep: [(from: String, to: String)], millis: [(from: TimeInterval, to: TimeInterval)]){
        
        let fromDateFD = Date(timeIntervalSince1970: fromDate/1000)
        let cal = Calendar(identifier: .gregorian)
        let newFromDate = cal.startOfDay(for: fromDateFD)

        var stringRep: [(from: String, to: String)] = []
        var millis: [(from: TimeInterval, to: TimeInterval)] = []
        
        let weekInMilliseconds: Double = 604800000
        var fromdate = Date.previousMonday(fromDate: newFromDate.timeIntervalSince1970 * 1000)
        let to = Date.nextSunday(fromDate: Date().timeIntervalSince1970 * 1000)
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
    
    static func previousMonday(fromDate date: TimeInterval) -> TimeInterval {
        
        var dateD = Date(timeIntervalSince1970: date/1000)
        print(dateD.description)
        let calender = Calendar.current
        var components = calender.component(.weekday, from: dateD)
        while components != 2 {
            var timeinterval = dateD.timeIntervalSince1970 * 1000
            timeinterval -= 86400000
            dateD = Date(timeIntervalSince1970: timeinterval/1000)
            components = calender.component(.weekday, from: dateD)
        }
        return dateD.timeIntervalSince1970 * 1000
    }
    
    static func nextSunday(fromDate date: TimeInterval) -> TimeInterval {
        var dateD = Date(timeIntervalSince1970: date/1000)
        print(dateD.description)
        let calender = Calendar.current
        var components = calender.component(.weekday, from: dateD)
        while components != 1 {
            var timeinterval = dateD.timeIntervalSince1970 * 1000
            timeinterval += 86400000
            dateD = Date(timeIntervalSince1970: timeinterval/1000)
            components = calender.component(.weekday, from: dateD)
        }
        return dateD.timeIntervalSince1970 * 1000
    }
    
}


class HelperFunctionsAndExtensions: NSObject {

}
