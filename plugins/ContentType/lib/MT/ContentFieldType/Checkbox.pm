package MT::ContentFieldType::Checkbox;
use strict;
use warnings;

use MT::ContentField;

sub field_html {
    my ( $app, $id, $value ) = @_;
    $value = [ $value ] unless ref $value eq 'ARRAY';

    my $content_field = MT::ContentField->load($id);
    my $options       = $content_field->options;
    my $options_delimiter
        = quotemeta(
        $app->registry('content_field_types')->{checkbox}{options_delimiter}
            || ',' );
    my @options = split $options_delimiter, $options;

    my $html    = '';
    my $count   = 1;

    foreach my $option (@options) {
        $html
            .= "<input type=\"checkbox\" name=\"content-field-$id\" id=\"content-field-$id-$count\" class=\"radio\" value=\"$option\"";
        $html
            .= ( grep { $_ eq $option } @$value ) ? ' checked="checked"' : '';
        $html .= " />";
        $html .= " <label for=\"content-field-$id-$count\">$option ";
        $count++;
    }
    return $html;
}

sub single_select_options {
    my $prop = shift;
    my $app = shift || MT->app;

    my $content_field_id = $prop->{content_field_id};
    my $content_field    = MT::ContentField->load($content_field_id);
    my $options_delimiter
        = quotemeta(
        $app->registry('content_field_types')->{checkbox}{options_delimiter}
            || ',' );
    my @options = split $options_delimiter, $content_field->options;

    [ map { +{ label => $_, value => $_ } } @options ];
}

sub data_getter {
    my ( $app, $id ) = @_;
    my @data = $app->param( "content-field-${id}" );
    \@data;
}

1;

