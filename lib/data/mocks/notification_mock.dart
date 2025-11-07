import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/notification_item_model.dart';

final List<NotificationItem> initialMockNotifications = [
  NotificationItem(
    icon: CupertinoIcons.doc_fill,
    title: 'Contrato Vencendo',
    subtitle: 'O contrato do imóvel #123456 (Rua X) vence em 5 dias.',
    color: Colors.red.shade700,
    time: '2 min atrás',
  ),
  NotificationItem(
    icon: CupertinoIcons.money_dollar_circle_fill,
    title: 'Pagamento Atrasado',
    subtitle: 'O inquilino do imóvel #789012 está com aluguel pendente.',
    color: Colors.orange.shade700,
    time: '1 hora atrás',
  ),
  NotificationItem(
    icon: CupertinoIcons.person_alt_circle_fill,
    title: 'Novo Lead',
    subtitle: 'Novo adquirente interessado em imóveis comerciais.',
    color: Colors.blue.shade700,
    time: 'Ontem',
  ),
  NotificationItem(
    icon: CupertinoIcons.house_fill,
    title: 'Novo Imóvel Cadastrado',
    subtitle: 'Imóvel residencial na região do Itaim Bibi disponível.',
    color: Colors.green.shade700,
    time: '3 dias atrás',
  ),
];
