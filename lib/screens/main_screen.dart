import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:woo_market_demo/utility/extensions/string_extensions.dart';

import '../data/example_data.dart';
import '../models/coin_model.dart';

import '../utility/resources/size_manager.dart';
import '../utility/resources/string_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final _tabList = [
    const Tab(text: AppConstantStrings.all),
    const Tab(text: AppConstantStrings.spot),
    const Tab(text: AppConstantStrings.futures),
  ];
  bool _isSortAsc = true;
  bool _noSearchResult = false;
  late TabController _tabController;
  final _textController =
      TextEditingController(text: AppConstantStrings.emptyString);
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedTabIndex = 0;

  /// 0. Data Table Column Base => sortable
  /// 1. Data Table Column Quote => not sortable
  /// 2. Data Table Column type => not sortable
  /// 3. Data Table Column Last Price => sortable
  /// 4. Data Table Column Volume => sortable
  /// so unSortableColumnIndex must be 1 or 2
  final int _unSortableColumnIndex = 1;
  int _currentSortColumn = 1;
  List<Coin>? _currentList;
  List<Coin>? _searchResult;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabList.length, vsync: this);
    _currentList = allData;
    _sortBaseQuoteTypeAsc;
    _tabControllerListener;
    _checkPriority();
  }

  void get _tabControllerListener =>
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
        switch (_selectedTabIndex) {
          case 0:
            _currentList = allData;
            _sortBaseQuoteTypeAsc;
            _currentSortColumn = _unSortableColumnIndex;
            _textController.text = AppConstantStrings.emptyString;
            _isSortAsc = true;
            _noSearchResult = false;
            _unFocusSearchNode();
            break;
          case 1:
            _currentList = getSpotList;
            _sortVolumeAsc;
            _currentSortColumn = _unSortableColumnIndex;
            _textController.text = AppConstantStrings.emptyString;
            _isSortAsc = true;
            _noSearchResult = false;
            _unFocusSearchNode();
            break;
          case 2:
            _currentList = getFuturesList;
            _sortVolumeAsc;
            _currentSortColumn = _unSortableColumnIndex;
            _textController.text = AppConstantStrings.emptyString;
            _isSortAsc = true;
            _noSearchResult = false;
            _unFocusSearchNode();
            break;
          default:
        }
      });
    });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: _tabList.length,
        child: Scaffold(
          appBar: _appBar,
          body: Column(
            children: [
              _getSearch,
              _noSearchResult ? _getDataNotFound : _getDataTable
            ],
          ),
        ),
      ),
    );
  }

  AppBar get _appBar => AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabList,
        ),
      );

  Widget get _getSearch => TextFormField(
        focusNode: _searchFocusNode,
        controller: _textController,
        autofillHints: _currentList!.map((coin) => coin.base),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
        onChanged: onSearchTextChanged,
      );

  Widget get _getDataNotFound => const Padding(
        padding: EdgeInsets.only(top: AppConstantPaddings.p50),
        child: Text(AppConstantStrings.noDataFound),
      );

  Widget get _getDataTable => Expanded(
        child: ListView(children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.resolveWith(getColor),
              columns: _getDataTableColumns,
              rows: _getDataTableRows,
              sortColumnIndex: _currentSortColumn,
              sortAscending: _isSortAsc,
            ),
          )
        ]),
      );

  List<DataColumn> get _getDataTableColumns => [
        _getBaseColumn,
        const DataColumn(label: Text(AppConstantStrings.quote)),
        const DataColumn(label: Text(AppConstantStrings.type)),
        _getLastPriceColumn,
        _getVolumeColumn,
      ];

  DataColumn get _getBaseColumn => DataColumn(
        label: const Text(AppConstantStrings.base),
        onSort: (columnIndex, _) {
          setState(() {
            _currentSortColumn = columnIndex;
            !_isSortAsc ? _sortBaseQuoteTypeAsc : _sortBaseQuoteTypeDesc;
            _isSortAsc = !_isSortAsc;
          });
        },
      );

  DataColumn get _getLastPriceColumn => DataColumn(
        label: const Text(AppConstantStrings.lastPrice),
        numeric: true,
        onSort: (columnIndex, _) {
          setState(() {
            _currentSortColumn = columnIndex;
            _isSortAsc ? _sortPriceAsc : _sortPriceDesc;
            _isSortAsc = !_isSortAsc;
          });
        },
      );

  DataColumn get _getVolumeColumn => DataColumn(
        label: const Text(AppConstantStrings.volume),
        numeric: true,
        onSort: (columnIndex, _) {
          setState(() {
            _currentSortColumn = columnIndex;
            _isSortAsc ? _sortVolumeAsc : _sortVolumeDesc;
            _isSortAsc = !_isSortAsc;
          });
        },
      );

  List<DataRow> get _getDataTableRows => _currentList!
      .map((item) => DataRow(
            cells: [
              DataCell(Text(item.base + '/' + item.quote)),
              DataCell(Text(item.quote)),
              DataCell(Text(item.type)),
              DataCell(Text(CommonCurrencies()
                  .usd
                  .parse(item.lastPrice.toString())
                  .format('S###,###.##'))),
              DataCell(Text(item.volume.toString().toKBMFormat()))
            ],
          ))
      .toList();

  _checkPriority() {
    var tmpBTCList = [];
    var tmpETHList = [];
    var tmpWOOList = [];

    for(var i=0; i<_currentList!.length; i++){
      switch(_currentList![i].base) {
        case AppConstantStrings.btc:
          tmpBTCList.add(_currentList![i]);
          _currentList!.removeAt(i);
          break;
        case AppConstantStrings.eth:
          tmpETHList.add(_currentList![i]);
          _currentList!.removeAt(i);
          break;
        case AppConstantStrings.woo:
          tmpWOOList.add(_currentList![i]);
          _currentList!.removeAt(i);
          break;
        default:
      }
    }
    _currentList = [...tmpBTCList, ...tmpETHList,...tmpWOOList, ..._currentList!];
    }


  void get _sortPriceAsc => _currentList!.sort(
        (a, b) => b.lastPrice.compareTo(a.lastPrice),
  );

  void get _sortPriceDesc => _currentList!.sort(
        (a, b) => a.lastPrice.compareTo(b.lastPrice),
  );

  void get _sortBaseQuoteTypeAsc => _currentList!.sort(
        (a, b) =>
        (a.base + a.quote + a.type).
        toString().toLowerCase().
        compareTo(
          (b.base + b.quote + b.type).
          toString().
          toLowerCase(),
        ),
  );

  void get _sortBaseQuoteTypeDesc => _currentList!.sort(
        (a, b) =>
        (b.base + b.quote + b.type).
        toString().
        toLowerCase().
        compareTo(
          (a.base + a.quote + a.type).
          toString().
          toLowerCase(),
        ),
  );

  void get _sortVolumeAsc =>
      _currentList!.sort((a, b) => b.volume.compareTo(a.volume));

  void get _sortVolumeDesc => _currentList!.sort(
        (a, b) => a.volume.compareTo(b.volume),
  );

  List<Coin> get getSpotList => allData
      .where((coin) => coin.type.toUpperCase() == AppConstantStrings.spot)
      .toList();

  List<Coin> get getFuturesList => allData
      .where((coin) => coin.type.toUpperCase() == AppConstantStrings.futures)
      .toList();

  void _unFocusSearchNode() {
    if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
  }

  void onSearchTextChanged(String value) {
    if (value.isEmpty) {
      _currentList = _getCurrentTabList;
      _searchResult = _currentList;
    }
    if (_noSearchResult) {
      _currentList = _getCurrentTabList;
      _noSearchResult = false;
      _searchResult = _currentList;
    } else {
      _currentList = _getCurrentTabList;
      _searchResult = _currentList;
    }

    _searchResult = _currentList!.where((item) {
      final base = item.base.toLowerCase();
      final type = item.type.toLowerCase();
      final lastPrice = item.lastPrice.toString().toLowerCase();
      final volume = item.volume.toString().toKBMFormat().toLowerCase();
      return base.contains(value) ||
          type.contains(value) ||
          lastPrice.contains(value) ||
          volume.contains(value);
    }).toList();

    (_searchResult != null && _searchResult!.isNotEmpty)
        ? _currentList = _searchResult
        : _noSearchResult = true;

    setState(() {});
  }

  List<Coin> get _getCurrentTabList => _selectedTabIndex == 1
      ? _currentList = getSpotList
      : _selectedTabIndex == 2
          ? _currentList = getFuturesList
          : _currentList = allData;

  Color? getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.selected,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blueGrey;
    }
    return null;
  }
}
