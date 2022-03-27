const List<String> roundTypeList = ['切捨', '切上'];
const List<int> roundNumList = [1, 5, 10, 15, 30];
const List<int> legalList = [8];
const List<String> weekList = ['日', '月', '火', '水', '木', '金', '土'];
const List<String> csvTemplates = ['ひろめカンパニー用レイアウト', '土佐税理士事務所用レイアウト'];

DateTime kMonthFirstDate = DateTime(DateTime.now().year - 1);
DateTime kMonthLastDate = DateTime(DateTime.now().year + 1);
DateTime kDayFirstDate = DateTime.now().subtract(Duration(days: 365));
DateTime kDayLastDate = DateTime.now().add(Duration(days: 365));
