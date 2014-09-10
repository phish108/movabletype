# Movable Type (r) (C) 2001-2014 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$
package MT::DataAPI::Endpoint::Category::v2;

use strict;
use warnings;

use MT::Util;
use MT::DataAPI::Endpoint::Common;
use MT::DataAPI::Resource;

sub create {
    my ( $app, $endpoint ) = @_;

    my ($blog) = context_objects(@_);
    return unless $blog && $blog->id;

    my $author = $app->user;

    my $orig_category = $app->model('category')->new;
    $orig_category->set_values(
        {   blog_id     => $blog->id,
            author_id   => $author->id,
            allow_pings => $blog->allow_pings_default,
        }
    );

    my $new_category = $app->resource_object( 'category', $orig_category )
        or return;

    if (   !defined( $new_category->basename )
        || $new_category->basename eq ''
        || $app->model('category')->exist(
            { blog_id => $blog->id, basename => $new_category->basename }
        )
        )
    {
        $new_category->basename(
            MT::Util::make_unique_category_basename($new_category) );
    }

    save_object( $app, 'category', $new_category )
        or return;

    $new_category;
}

sub get {
    my ( $app, $endpoint ) = @_;

    my ( $blog, $category ) = context_objects(@_)
        or return;

    run_permission_filter( $app, 'data_api_view_permission_filter',
        'category', $category->id, obj_promise($category) )
        or return;

    $category;
}

sub update {
    my ( $app, $endpoint ) = @_;

    my ( $blog, $orig_category ) = context_objects(@_)
        or return;
    my $new_category = $app->resource_object( 'category', $orig_category )
        or return;

    save_object(
        $app,
        'category',
        $new_category,
        $orig_category,
        sub {
            $new_category->modified_by( $app->user->id );
            $_[0]->();
        }
    ) or return;

    $new_category;
}

sub delete {
    my ( $app, $endpoint ) = @_;

    my ( $blog, $category ) = context_objects(@_)
        or return;

    run_permission_filter( $app, 'data_api_delete_permission_filter',
        'category', $category )
        or return;

    require MT::CMS::Category;
    MT::CMS::Category::pre_delete( $app, $category )
        or return;

    $category->remove
        or return $app->error(
        $app->translate(
            'Removing [_1] failed: [_2]', $category->class_label,
            $category->errstr
        ),
        500
        );

    $app->run_callbacks( 'data_api_post_delete.category', $app, $category );

    $category;
}

1;

__END__

=head1 NAME

MT::DataAPI::Endpoint::Category::v2 - Movable Type class for endpoint definitions about the MT::Category.

=head1 AUTHOR & COPYRIGHT

Please see the I<MT> manpage for author, copyright, and license information.

=cut
