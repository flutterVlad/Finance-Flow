import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '/data/mappers/account_mapper.dart';
import '/data/models/account/account.dart';
import '/data/service/image_picker.dart';
import '/l10n/app_localizations.dart';
import '/presentation/bloc/settings/settings_bloc.dart';
import '/presentation/screens/home_screen/widgets/avatar_view.dart';
import '/utils/widgets/inputs/text_input.dart';
import '/utils/widgets/primary_button.dart';

enum FormMode { create, edit }

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key, this.account})
    : mode = account == null ? FormMode.create : FormMode.edit;

  final Account? account;
  final FormMode mode;

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late final ValueNotifier<AccountForm> formNotifier;

  @override
  void initState() {
    super.initState();

    formNotifier = ValueNotifier(
      widget.account?.toForm() ?? const AccountForm(),
    );
  }

  @override
  void dispose() {
    formNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    final s = S.of(context);

    return Nested(
      children: [
        BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state.response != null) if (context.canPop()) context.pop();
          },
        ),
        ChangeNotifierProvider.value(value: formNotifier),
      ],
      child: Scaffold(
        extendBody: true,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                widget.mode == FormMode.create
                    ? s.createAccount
                    : s.editAccount,
                style: const TextStyle(fontWeight: .bold),
              ),
              centerTitle: true,
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const .only(right: 16, left: 16, top: 16),
                child: _AvatarSection(formNotifier: formNotifier),
              ),
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: formNotifier,
                builder: (context, form, _) {
                  return _EmailSection(
                    form: form,
                    onChanged: (updated) => formNotifier.value = updated,
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: formNotifier,
                builder: (context, form, _) {
                  return _FirstNameSection(
                    form: form,
                    onChanged: (updated) => formNotifier.value = updated,
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: formNotifier,
                builder: (context, form, _) {
                  return _LastNameSection(
                    form: form,
                    onChanged: (updated) => formNotifier.value = updated,
                  );
                },
              ),
            ),
            if (settingsBloc.state.allAccounts.length > 1)
              SliverPadding(
                padding: const .only(top: 16, left: 16, right: 16),
                sliver: SliverToBoxAdapter(
                  child: ValueListenableBuilder(
                    valueListenable: formNotifier,
                    builder: (context, form, _) {
                      return Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Text(
                            s.makeThisAccountPrimary,
                            style: const TextStyle(fontWeight: .w600),
                          ),
                          Switch.adaptive(
                            value: form.isPrimary,
                            onChanged: (value) => formNotifier.value = form
                                .copyWith(isPrimary: value),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const .symmetric(horizontal: 16),
            child: ValueListenableBuilder(
              valueListenable: formNotifier,
              builder: (context, form, _) {
                return PrimaryButton(
                  enabled:
                      form.isValid && !form.equals(widget.account?.toForm()),
                  onTap: () =>
                      settingsBloc.add(SavePersonInfoEvent(form: form)),
                  text: widget.mode == FormMode.create ? s.create : s.save,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.formNotifier});

  final ValueNotifier<AccountForm> formNotifier;

  @override
  Widget build(BuildContext context) {
    return Selector<ValueNotifier<AccountForm>, Uint8List?>(
      selector: (context, value) => value.value.image,
      builder: (context, image, _) {
        return Center(
          child: AvatarView(
            image: image,
            imageSize: 80,
            isPreview: false,
            onTap: () async {
              final form = context.read<ValueNotifier<AccountForm>>().value;
              final image = await const ImagePickerService().pickImage();
              if (image != null) {
                formNotifier.value = form.copyWith(image: image);
              }
            },
          ),
        );
      },
    );
  }
}

class _EmailSection extends StatelessWidget {
  const _EmailSection({required this.form, required this.onChanged});

  final AccountForm form;
  final ValueChanged<AccountForm> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(right: 16, left: 16, top: 16),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 8,
        children: [
          Text(S.of(context).email, style: const TextStyle(fontWeight: .w600)),
          TextInput(
            text: form.email.value,
            keyboardType: .emailAddress,
            onChanged: (value) =>
                onChanged(form.copyWith(email: .dirty(value))),
            errorText: form.email.displayError,
          ),
        ],
      ),
    );
  }
}

class _FirstNameSection extends StatelessWidget {
  const _FirstNameSection({required this.form, required this.onChanged});

  final AccountForm form;
  final ValueChanged<AccountForm> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(right: 16, left: 16, top: 16),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 8,
        children: [
          Text(
            S.of(context).firstName,
            style: const TextStyle(fontWeight: .w600),
          ),
          TextInput(
            text: form.firstName.value,
            onChanged: (value) =>
                onChanged(form.copyWith(firstName: .dirty(value))),
            errorText: form.firstName.displayError,
          ),
        ],
      ),
    );
  }
}

class _LastNameSection extends StatelessWidget {
  const _LastNameSection({required this.form, required this.onChanged});

  final AccountForm form;
  final ValueChanged<AccountForm> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(right: 16, left: 16, top: 16),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 8,
        children: [
          Text(
            S.of(context).lastName,
            style: const TextStyle(fontWeight: .w600),
          ),
          TextInput(
            text: form.lastName.value,
            onChanged: (value) =>
                onChanged(form.copyWith(lastName: .dirty(value))),
            errorText: form.lastName.displayError,
          ),
        ],
      ),
    );
  }
}
