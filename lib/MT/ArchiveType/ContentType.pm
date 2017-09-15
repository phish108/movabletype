# Movable Type (r) (C) 2001-2017 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package MT::ArchiveType::ContentType;

use strict;
use base qw( MT::ArchiveType );

use MT::Util qw( remove_html encode_html );

sub name {
    return 'ContentType';
}

sub archive_label {
    return MT->translate("CONTENTTYPE_ADV");
}

sub template_params {
    return {
        archive_class        => "contenttype-archive",
        contenttype_archive  => 1,
        archive_template     => 1,
        archive_listing      => 1,
    };
}

sub dynamic_template {
    'content/<$MTContentID$>';
}

sub archive_file {
    my $obj = shift;
    my ( $ctx, %param ) = @_;
    my $timestamp = $param{Timestamp};
    my $file_tmpl = $param{Template};
    my $blog      = $ctx->{__stash}{blog};
    my $content   = $ctx->{__stash}{content};

    my $file;
    Carp::confess("archive_file_for ContentType archive needs an content")
        unless $content;
    if ($file_tmpl) {
        $ctx->{current_timestamp} = $timestamp;
    }
    else {
        my $basename = $content->identifier();
        $basename ||= dirify( $content->label() );
        $file = sprintf( "%04d/%02d/%s",
            unpack( 'A4A2', $timestamp ), $basename );
    }
    $file;
}

sub archive_title {
    my $obj = shift;
    encode_html( remove_html( $_[1]->title ) );
}

sub archive_group_iter {
    my $obj = shift;
    my ( $ctx, $args ) = @_;

    my $order
        = ( $args->{sort_order} || '' ) eq 'ascend' ? 'ascend' : 'descend';

    my $blog_id = $ctx->stash('blog')->id;
    require MT::ContentData;
    my $iter = MT::ContentData->load_iter(
        {   blog_id => $blog_id,
            status  => MT::Entry::RELEASE()
        },
        {   'sort'    => 'authored_on',
            direction => $order,
            $args->{lastn} ? ( limit => $args->{lastn} ) : ()
        }
    );
    return sub {
        while ( my $content = $iter->() ) {
            return ( 1, contents => [$content], content => $content );
        }
        undef;
        }
}

sub default_archive_templates {
    return [
        {   label           => MT->translate('yyyy/mm/base-name.html'),
            template        => '%y/%m/%-f',
            default         => 1,
            required_fields => { date_and_time => 1 }
        },
        {   label           => MT->translate('yyyy/mm/base_name.html'),
            template        => '%y/%m/%f',
            required_fields => { date_and_time => 1 }
        },
        {   label           => MT->translate('yyyy/mm/base-name/index.html'),
            template        => '%y/%m/%-b/%i',
            required_fields => { date_and_time => 1 }
        },
        {   label           => MT->translate('yyyy/mm/base_name/index.html'),
            template        => '%y/%m/%b/%i',
            required_fields => { date_and_time => 1 }
        },
        {   label           => MT->translate('yyyy/mm/dd/base-name.html'),
            template        => '%y/%m/%d/%-f',
            required_fields => { date_and_time => 1 }
        },
        {   label           => MT->translate('yyyy/mm/dd/base_name.html'),
            template        => '%y/%m/%d/%f',
            required_fields => { date_and_time => 1 }
        },
        {   label    => MT->translate('yyyy/mm/dd/base-name/index.html'),
            template => '%y/%m/%d/%-b/%i',
            required_fields => { date_and_time => 1 }
        },
        {   label    => MT->translate('yyyy/mm/dd/base_name/index.html'),
            template => '%y/%m/%d/%b/%i',
            required_fields => { date_and_time => 1 }
        },
        {   label    => MT->translate('category/sub-category/base-name.html'),
            template => '%-c/%-f',
            required_fields => { category => 1 }
        },
        {   label =>
                MT->translate('category/sub-category/base-name/index.html'),
            template        => '%-c/%-b/%i',
            required_fields => { category => 1 }
        },
        {   label    => MT->translate('category/sub_category/base_name.html'),
            template => '%c/%f',
            required_fields => { category => 1 }
        },
        {   label =>
                MT->translate('category/sub_category/base_name/index.html'),
            template        => '%c/%b/%i',
            required_fields => { category => 1 }
        },
    ];
}

1;
