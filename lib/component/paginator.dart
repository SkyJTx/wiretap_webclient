import 'package:flutter/material.dart';

class Paginator extends StatefulWidget {
  final int totalPage;
  final int currentPage;
  final Function(int) onPageChanged;

  const Paginator({
    super.key,
    required this.totalPage,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  PaginatorState createState() => PaginatorState();
}

class PaginatorState extends State<Paginator> {
  late int _currentPage;
  late int _totalPage;

  @override
  void initState() {
    _currentPage = widget.currentPage;
    _totalPage = widget.totalPage;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Paginator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      setState(() {
        _currentPage = widget.currentPage;
      });
    }
    if (oldWidget.totalPage != widget.totalPage) {
      setState(() {
        _totalPage = widget.totalPage;
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    widget.onPageChanged(page);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _currentPage > 1 ? Theme.of(context).colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back, 
              color: _currentPage > 1 ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
            ),
          ),
        ),
        Text('Page $_currentPage of $_totalPage'),
        InkWell(
          onTap: _currentPage < _totalPage ? () => _onPageChanged(_currentPage + 1) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _currentPage < _totalPage ? Theme.of(context).colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_forward, 
              color: _currentPage < _totalPage ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
