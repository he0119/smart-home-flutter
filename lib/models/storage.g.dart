// GENERATED CODE - DO NOT MODIFY BY HAND

part of storage;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Storage> _$storageSerializer = new _$StorageSerializer();
Serializer<Item> _$itemSerializer = new _$ItemSerializer();

class _$StorageSerializer implements StructuredSerializer<Storage> {
  @override
  final Iterable<Type> types = const [Storage, _$Storage];
  @override
  final String wireName = 'Storage';

  @override
  Iterable<Object> serialize(Serializers serializers, Storage object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];
    if (object.id != null) {
      result
        ..add('id')
        ..add(serializers.serialize(object.id,
            specifiedType: const FullType(String)));
    }
    if (object.parent != null) {
      result
        ..add('parent')
        ..add(serializers.serialize(object.parent,
            specifiedType: const FullType(Storage)));
    }
    if (object.description != null) {
      result
        ..add('description')
        ..add(serializers.serialize(object.description,
            specifiedType: const FullType(String)));
    }
    if (object.children != null) {
      result
        ..add('children')
        ..add(serializers.serialize(object.children,
            specifiedType:
                const FullType(BuiltList, const [const FullType(Storage)])));
    }
    if (object.items != null) {
      result
        ..add('items')
        ..add(serializers.serialize(object.items,
            specifiedType:
                const FullType(BuiltList, const [const FullType(Item)])));
    }
    return result;
  }

  @override
  Storage deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new StorageBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'parent':
          result.parent.replace(serializers.deserialize(value,
              specifiedType: const FullType(Storage)) as Storage);
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'children':
          result.children.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(Storage)]))
              as BuiltList<Object>);
          break;
        case 'items':
          result.items.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(Item)]))
              as BuiltList<Object>);
          break;
      }
    }

    return result.build();
  }
}

class _$ItemSerializer implements StructuredSerializer<Item> {
  @override
  final Iterable<Type> types = const [Item, _$Item];
  @override
  final String wireName = 'Item';

  @override
  Iterable<Object> serialize(Serializers serializers, Item object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'number',
      serializers.serialize(object.number, specifiedType: const FullType(int)),
      'storage',
      serializers.serialize(object.storage,
          specifiedType: const FullType(Storage)),
    ];
    if (object.id != null) {
      result
        ..add('id')
        ..add(serializers.serialize(object.id,
            specifiedType: const FullType(String)));
    }
    if (object.description != null) {
      result
        ..add('description')
        ..add(serializers.serialize(object.description,
            specifiedType: const FullType(String)));
    }
    if (object.price != null) {
      result
        ..add('price')
        ..add(serializers.serialize(object.price,
            specifiedType: const FullType(double)));
    }
    if (object.expirationDate != null) {
      result
        ..add('expirationDate')
        ..add(serializers.serialize(object.expirationDate,
            specifiedType: const FullType(DateTime)));
    }
    if (object.editor != null) {
      result
        ..add('editor')
        ..add(serializers.serialize(object.editor,
            specifiedType: const FullType(User)));
    }
    if (object.updateDate != null) {
      result
        ..add('updateDate')
        ..add(serializers.serialize(object.updateDate,
            specifiedType: const FullType(DateTime)));
    }
    return result;
  }

  @override
  Item deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'number':
          result.number = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'storage':
          result.storage.replace(serializers.deserialize(value,
              specifiedType: const FullType(Storage)) as Storage);
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'price':
          result.price = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'expirationDate':
          result.expirationDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
        case 'editor':
          result.editor.replace(serializers.deserialize(value,
              specifiedType: const FullType(User)) as User);
          break;
        case 'updateDate':
          result.updateDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$Storage extends Storage {
  @override
  final String id;
  @override
  final String name;
  @override
  final Storage parent;
  @override
  final String description;
  @override
  final BuiltList<Storage> children;
  @override
  final BuiltList<Item> items;

  factory _$Storage([void Function(StorageBuilder) updates]) =>
      (new StorageBuilder()..update(updates)).build();

  _$Storage._(
      {this.id,
      this.name,
      this.parent,
      this.description,
      this.children,
      this.items})
      : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('Storage', 'name');
    }
  }

  @override
  Storage rebuild(void Function(StorageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StorageBuilder toBuilder() => new StorageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Storage &&
        id == other.id &&
        name == other.name &&
        parent == other.parent &&
        description == other.description &&
        children == other.children &&
        items == other.items;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc($jc($jc(0, id.hashCode), name.hashCode), parent.hashCode),
                description.hashCode),
            children.hashCode),
        items.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Storage')
          ..add('id', id)
          ..add('name', name)
          ..add('parent', parent)
          ..add('description', description)
          ..add('children', children)
          ..add('items', items))
        .toString();
  }
}

class StorageBuilder implements Builder<Storage, StorageBuilder> {
  _$Storage _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  StorageBuilder _parent;
  StorageBuilder get parent => _$this._parent ??= new StorageBuilder();
  set parent(StorageBuilder parent) => _$this._parent = parent;

  String _description;
  String get description => _$this._description;
  set description(String description) => _$this._description = description;

  ListBuilder<Storage> _children;
  ListBuilder<Storage> get children =>
      _$this._children ??= new ListBuilder<Storage>();
  set children(ListBuilder<Storage> children) => _$this._children = children;

  ListBuilder<Item> _items;
  ListBuilder<Item> get items => _$this._items ??= new ListBuilder<Item>();
  set items(ListBuilder<Item> items) => _$this._items = items;

  StorageBuilder();

  StorageBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _name = _$v.name;
      _parent = _$v.parent?.toBuilder();
      _description = _$v.description;
      _children = _$v.children?.toBuilder();
      _items = _$v.items?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Storage other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Storage;
  }

  @override
  void update(void Function(StorageBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Storage build() {
    _$Storage _$result;
    try {
      _$result = _$v ??
          new _$Storage._(
              id: id,
              name: name,
              parent: _parent?.build(),
              description: description,
              children: _children?.build(),
              items: _items?.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'parent';
        _parent?.build();

        _$failedField = 'children';
        _children?.build();
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Storage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$Item extends Item {
  @override
  final String id;
  @override
  final String name;
  @override
  final int number;
  @override
  final Storage storage;
  @override
  final String description;
  @override
  final double price;
  @override
  final DateTime expirationDate;
  @override
  final User editor;
  @override
  final DateTime updateDate;

  factory _$Item([void Function(ItemBuilder) updates]) =>
      (new ItemBuilder()..update(updates)).build();

  _$Item._(
      {this.id,
      this.name,
      this.number,
      this.storage,
      this.description,
      this.price,
      this.expirationDate,
      this.editor,
      this.updateDate})
      : super._() {
    if (name == null) {
      throw new BuiltValueNullFieldError('Item', 'name');
    }
    if (number == null) {
      throw new BuiltValueNullFieldError('Item', 'number');
    }
    if (storage == null) {
      throw new BuiltValueNullFieldError('Item', 'storage');
    }
  }

  @override
  Item rebuild(void Function(ItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ItemBuilder toBuilder() => new ItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Item &&
        id == other.id &&
        name == other.name &&
        number == other.number &&
        storage == other.storage &&
        description == other.description &&
        price == other.price &&
        expirationDate == other.expirationDate &&
        editor == other.editor &&
        updateDate == other.updateDate;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc($jc($jc(0, id.hashCode), name.hashCode),
                                number.hashCode),
                            storage.hashCode),
                        description.hashCode),
                    price.hashCode),
                expirationDate.hashCode),
            editor.hashCode),
        updateDate.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Item')
          ..add('id', id)
          ..add('name', name)
          ..add('number', number)
          ..add('storage', storage)
          ..add('description', description)
          ..add('price', price)
          ..add('expirationDate', expirationDate)
          ..add('editor', editor)
          ..add('updateDate', updateDate))
        .toString();
  }
}

class ItemBuilder implements Builder<Item, ItemBuilder> {
  _$Item _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  int _number;
  int get number => _$this._number;
  set number(int number) => _$this._number = number;

  StorageBuilder _storage;
  StorageBuilder get storage => _$this._storage ??= new StorageBuilder();
  set storage(StorageBuilder storage) => _$this._storage = storage;

  String _description;
  String get description => _$this._description;
  set description(String description) => _$this._description = description;

  double _price;
  double get price => _$this._price;
  set price(double price) => _$this._price = price;

  DateTime _expirationDate;
  DateTime get expirationDate => _$this._expirationDate;
  set expirationDate(DateTime expirationDate) =>
      _$this._expirationDate = expirationDate;

  UserBuilder _editor;
  UserBuilder get editor => _$this._editor ??= new UserBuilder();
  set editor(UserBuilder editor) => _$this._editor = editor;

  DateTime _updateDate;
  DateTime get updateDate => _$this._updateDate;
  set updateDate(DateTime updateDate) => _$this._updateDate = updateDate;

  ItemBuilder();

  ItemBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _name = _$v.name;
      _number = _$v.number;
      _storage = _$v.storage?.toBuilder();
      _description = _$v.description;
      _price = _$v.price;
      _expirationDate = _$v.expirationDate;
      _editor = _$v.editor?.toBuilder();
      _updateDate = _$v.updateDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Item other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Item;
  }

  @override
  void update(void Function(ItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Item build() {
    _$Item _$result;
    try {
      _$result = _$v ??
          new _$Item._(
              id: id,
              name: name,
              number: number,
              storage: storage.build(),
              description: description,
              price: price,
              expirationDate: expirationDate,
              editor: _editor?.build(),
              updateDate: updateDate);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'storage';
        storage.build();

        _$failedField = 'editor';
        _editor?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Item', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
